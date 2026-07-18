import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/common/theme/app_theme.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:snapconnect/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/register_usecase.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/pages/register_page.dart';

class _FakeAuthRepository implements IAuthRepository {
  Map<String, dynamic>? lastRegisterData;
  bool registerResult = true;

  @override
  Future<bool> register(Map<String, dynamic> data) async {
    lastRegisterData = data;
    return registerResult;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> whoAmI() async => null;

  @override
  Future<void> logout() async {}
}

class _NoopAppLogger implements AppLogger {
  @override
  void verbose(String message) {}
  @override
  void debug(String message) {}
  @override
  void info(String message) {}
  @override
  void warning(String message) {}
  @override
  void good(String message) {}
  @override
  void error(String message, [Object? exception, StackTrace? stackTrace]) {}
  @override
  void handle(Object exception, StackTrace stackTrace, [String? message]) {}
  @override
  dynamic get coreLogger => null;
}

Widget _wrap(AuthCubit cubit, {required ThemeData theme}) {
  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider.value(
          value: cubit,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Text('LOGIN SCREEN')),
      ),
    ],
  );
  return MaterialApp.router(theme: theme, routerConfig: router);
}

void main() {
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUpAll(() {
    if (!sl.isRegistered<AppLogger>()) {
      sl.registerLazySingleton<AppLogger>(() => _NoopAppLogger());
    }
  });

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      checkAuthUseCase: CheckAuthUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  for (final themeName in ['light', 'dark']) {
    testWidgets('sign-up flow slides through all steps ($themeName theme)',
        (tester) async {
      final theme = themeName == 'light' ? AppTheme.light : AppTheme.dark;
      await tester.pumpWidget(_wrap(cubit, theme: theme));
      await tester.pumpAndSettle();

      // Welcome step
      expect(find.text('Welcome to SnapConnect'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      // Email step — empty submit shows validation error
      expect(find.text("What's your email?"), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'demo@example.com');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Username step
      expect(find.text('Choose a username'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'demo_user');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Password step
      expect(find.text('Create a password'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'password123');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Confirm password step — mismatch shows validation error
      expect(find.text('Confirm your password'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'wrongpass');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'password123');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Phone step — optional, greets by username, has a Skip action
      expect(find.text('Hi @demo_user'), findsOneWidget);
      expect(find.text("What's your phone number?"), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Register submitted with the collected fields and redirected to login.
      expect(repo.lastRegisterData, {
        'username': 'demo_user',
        'email': 'demo@example.com',
        'password': 'password123',
        'confirmPassword': 'password123',
        'phone': '',
      });
      expect(find.text('LOGIN SCREEN'), findsOneWidget);
    });
  }

  testWidgets('back caret steps backward instead of exiting the flow',
      (tester) async {
    await tester.pumpWidget(_wrap(cubit, theme: AppTheme.light));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text("What's your email?"), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'demo@example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a username'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text("What's your email?"), findsOneWidget);
  });

  testWidgets('phone step can be skipped without a value', (tester) async {
    await tester.pumpWidget(_wrap(cubit, theme: AppTheme.light));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'demo@example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'demo_user');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'password123');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'password123');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Skip for now'), findsOneWidget);
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(repo.lastRegisterData?['phone'], '');
    expect(find.text('LOGIN SCREEN'), findsOneWidget);
  });
}
