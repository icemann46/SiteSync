import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/features/auth/domain/entities/app_user.dart';
import 'package:site_sync/features/auth/domain/entities/sign_up_result.dart';
import 'package:site_sync/features/auth/domain/entities/user_role.dart';
import 'package:site_sync/features/auth/domain/repositories/auth_repository.dart';
import 'package:site_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:site_sync/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:site_sync/features/projects/domain/entities/project.dart';
import 'package:site_sync/features/projects/domain/entities/project_input.dart';
import 'package:site_sync/features/projects/domain/repositories/project_repository.dart';
import 'package:site_sync/features/projects/presentation/providers/projects_provider.dart';
import 'package:site_sync/main.dart';

void main() {
  testWidgets('redirects unauthenticated users to login', (tester) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('SiteSync'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('routes GC users to the contractor shell', (tester) async {
    final repository = _FakeAuthRepository(currentUser: _gcUser);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('SiteSync Contractor'), findsOneWidget);
    expect(find.text('Projects'), findsWidgets);
  });

  testWidgets('routes client users to the client shell', (tester) async {
    final repository = _FakeAuthRepository(currentUser: _clientUser);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('SiteSync Client'), findsOneWidget);
    expect(find.text('My Projects'), findsWidgets);
  });

  testWidgets('sign up submits selected role and shows confirmation state', (tester) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("I'm a Client"));
    await tester.enterText(find.byType(TextFormField).at(0), 'Client User');
    await tester.enterText(find.byType(TextFormField).at(1), 'client@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(repository.lastSignUpRole, UserRole.client);
    expect(repository.lastSignUpDisplayName, 'Client User');
    expect(find.text('Check client@example.com for a confirmation link before logging in.'), findsOneWidget);
  });

  testWidgets('forgot password submits a reset email request', (tester) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'client@example.com');
    await tester.tap(find.text('Send reset email'));
    await tester.pumpAndSettle();

    expect(repository.passwordResetEmail, 'client@example.com');
    expect(find.text('Password reset email sent to client@example.com.'), findsOneWidget);
  });

  testWidgets('reset password submits a new password', (tester) async {
    final repository = _FakeAuthRepository(currentUser: _clientUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ResetPasswordScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'newpass123');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpass123');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(repository.updatedPassword, 'newpass123');
    expect(find.text('Password updated. You can continue in SiteSync.'), findsOneWidget);
  });

  testWidgets('logout redirects back to login', (tester) async {
    final repository = _FakeAuthRepository(currentUser: _gcUser);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalled, isTrue);
    expect(find.text('SiteSync'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}

Widget _app(_FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      projectRepositoryProvider.overrideWithValue(_NoopProjectRepository()),
    ],
    child: const SiteSyncApp(),
  );
}

const _gcUser = AppUser(
  id: 'gc-1',
  email: 'gc@example.com',
  role: UserRole.gc,
  displayName: 'General Contractor',
);

const _clientUser = AppUser(
  id: 'client-1',
  email: 'client@example.com',
  role: UserRole.client,
  displayName: 'Client User',
);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this._currentUser});

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  UserRole? lastSignUpRole;
  String? lastSignUpDisplayName;
  String? passwordResetEmail;
  String? updatedPassword;
  bool signOutCalled = false;

  @override
  Future<AppUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _currentUser = _gcUser;
    _controller.add(_currentUser);
    return _gcUser;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    lastSignUpRole = role;
    lastSignUpDisplayName = displayName;
    return SignUpResult(
      email: email.trim(),
      needsEmailConfirmation: true,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    passwordResetEmail = email;
  }

  @override
  Future<void> updatePassword({required String password}) async {
    updatedPassword = password;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _currentUser = null;
    _controller.add(null);
  }
}

class _NoopProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> getProjects() async {
    return const [];
  }

  @override
  Future<Project?> getProjectById(String id) async {
    return null;
  }

  @override
  Future<Project> createProject(ProjectInput input) {
    throw UnimplementedError();
  }

  @override
  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> archiveProject(String id) {
    throw UnimplementedError();
  }
}
