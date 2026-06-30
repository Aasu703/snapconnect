import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';

/// Base state for authentication.
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {}

/// Auth operation is in progress.
class AuthLoading extends AuthState {}

/// User is authenticated with an active session.
class Authenticated extends AuthState {
  final UserModel user;
  final String? token;

  Authenticated({required this.user, this.token});

  @override
  List<Object?> get props => [user, token];
}

/// No active session — user must log in.
class Unauthenticated extends AuthState {}

/// Registration completed successfully — redirect to login.
class RegisterSuccess extends AuthState {}

/// An error occurred during authentication.
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
