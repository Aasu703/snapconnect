import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/common/widgets/app_nav_bar.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/blocs/upload_bloc.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Scaffold shared by every authenticated route: hosts the current page
/// plus the bottom [AppNavBar], and owns the tab <-> route mapping.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int _currentIndex(String route) {
    if (route.startsWith(RoutePaths.events)) {
      return 1;
    }
    if (route.startsWith(RoutePaths.party)) {
      return 2;
    }
    if (route.startsWith(RoutePaths.upload)) {
      return 3;
    }
    if (route.startsWith(RoutePaths.profile)) {
      return 4;
    }
    return 0;
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return RoutePaths.home;
      case 1:
        return RoutePaths.events;
      case 2:
        return RoutePaths.party;
      case 4:
        return RoutePaths.profile;
      default:
        return RoutePaths.home;
    }
  }

  Future<void> _openUpload(BuildContext context) async {
    if (location.startsWith(RoutePaths.upload)) {
      return;
    }

    if (context.read<SessionCubit>().state == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Before uploading',
        subtitle: 'Set your identity before uploading photos.',
      );
    }

    if (!context.mounted || context.read<SessionCubit>().state == null) {
      return;
    }

    context.push(RoutePaths.upload);
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(location);

    return BlocBuilder<UploadBloc, UploadState>(
      builder: (context, uploadState) {
        final progress = uploadState.totalCount == 0
            ? 0.0
            : uploadState.uploadedCount / uploadState.totalCount;

        return Scaffold(
          body: child,
          bottomNavigationBar: AppNavBar(
            currentIndex: index,
            uploadInProgress: uploadState.isUploading,
            uploadProgress: progress,
            onTap: (selectedIndex) {
              if (selectedIndex == 3) {
                _openUpload(context);
                return;
              }

              final route = _routeForIndex(selectedIndex);
              if (location == route) {
                return;
              }

              context.go(route);
            },
          ),
        );
      },
    );
  }
}
