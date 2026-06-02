import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_loading_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/client/presentation/screens/client_shell_screen.dart';
import '../../features/gc/presentation/screens/gc_shell_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/project_form_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';

part 'app_router.g.dart';

const _publicPaths = {
  '/login',
  '/signup',
  '/forgot-password',
  '/reset-password',
};

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  final currentUser = switch (authState) {
    AsyncData(:final value) => value,
    _ => null,
  };
  final isInitialAuthLoad = authState.isLoading && !authState.hasValue;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublicPath = _publicPaths.contains(path);

      if (isInitialAuthLoad) {
        return null;
      }

      if (currentUser == null) {
        return isPublicPath ? null : '/login';
      }

      final homePath = currentUser.role.homePath;

      if (path == '/' || (isPublicPath && path != '/reset-password')) {
        return homePath;
      }

      if (currentUser.role == UserRole.gc && path.startsWith('/client')) {
        return homePath;
      }

      if (currentUser.role == UserRole.client && path.startsWith('/gc')) {
        return homePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/gc/projects',
        builder: (context, state) => const GcShellScreen(
          activeTab: GcShellTab.projects,
          body: ProjectListScreen(),
        ),
      ),
      GoRoute(
        path: '/gc/projects/new',
        builder: (context, state) => const GcShellScreen(
          activeTab: GcShellTab.projects,
          body: ProjectFormScreen(),
        ),
      ),
      GoRoute(
        path: '/gc/projects/:projectId/edit',
        builder: (context, state) => GcShellScreen(
          activeTab: GcShellTab.projects,
          body: ProjectFormScreen(projectId: state.pathParameters['projectId']),
        ),
      ),
      GoRoute(
        path: '/gc/projects/:projectId',
        builder: (context, state) => GcShellScreen(
          activeTab: GcShellTab.projects,
          body: ProjectDetailScreen(projectId: state.pathParameters['projectId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/gc/schedule',
        builder: (context, state) => const GcShellScreen(activeTab: GcShellTab.schedule),
      ),
      GoRoute(
        path: '/gc/settings',
        builder: (context, state) => const GcShellScreen(activeTab: GcShellTab.settings),
      ),
      GoRoute(
        path: '/client/my-projects',
        builder: (context, state) => const ClientShellScreen(activeTab: ClientShellTab.myProjects),
      ),
      GoRoute(
        path: '/client/settings',
        builder: (context, state) => const ClientShellScreen(activeTab: ClientShellTab.settings),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthLoadingScreen(),
      ),
    ],
  );
}
