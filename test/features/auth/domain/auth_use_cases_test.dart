import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/features/auth/domain/entities/app_user.dart';
import 'package:site_sync/features/auth/domain/entities/sign_up_result.dart';
import 'package:site_sync/features/auth/domain/entities/user_role.dart';
import 'package:site_sync/features/auth/domain/repositories/auth_repository.dart';
import 'package:site_sync/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:site_sync/features/auth/domain/usecases/send_password_reset_email_use_case.dart';
import 'package:site_sync/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:site_sync/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:site_sync/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:site_sync/features/auth/domain/usecases/update_password_use_case.dart';

void main() {
  group('auth use cases', () {
    late _RecordingAuthRepository repository;

    setUp(() {
      repository = _RecordingAuthRepository();
    });

    test('get current user delegates to repository', () async {
      repository.currentUser = _gcUser;

      final user = await GetCurrentUserUseCase(repository)();

      expect(user, _gcUser);
    });

    test('sign in delegates credentials and returns app user', () async {
      final user = await SignInUseCase(repository)(
        email: 'gc@example.com',
        password: 'secret123',
      );

      expect(user, _gcUser);
      expect(repository.signInEmail, 'gc@example.com');
      expect(repository.signInPassword, 'secret123');
    });

    test('sign up delegates role and profile fields', () async {
      final result = await SignUpUseCase(repository)(
        email: 'client@example.com',
        password: 'secret123',
        displayName: 'Client User',
        role: UserRole.client,
      );

      expect(result.needsEmailConfirmation, isTrue);
      expect(repository.signUpRole, UserRole.client);
      expect(repository.signUpDisplayName, 'Client User');
    });

    test('password reset and update password delegate to repository', () async {
      await SendPasswordResetEmailUseCase(repository)(email: 'client@example.com');
      await UpdatePasswordUseCase(repository)(password: 'newpass123');

      expect(repository.resetEmail, 'client@example.com');
      expect(repository.updatedPassword, 'newpass123');
    });

    test('sign out delegates to repository', () async {
      await SignOutUseCase(repository)();

      expect(repository.signOutCalled, isTrue);
    });
  });
}

const _gcUser = AppUser(
  id: 'user-1',
  email: 'gc@example.com',
  role: UserRole.gc,
  displayName: 'GC User',
);

class _RecordingAuthRepository implements AuthRepository {
  AppUser? currentUser;
  String? signInEmail;
  String? signInPassword;
  String? signUpEmail;
  String? signUpPassword;
  String? signUpDisplayName;
  UserRole? signUpRole;
  String? resetEmail;
  String? updatedPassword;
  bool signOutCalled = false;

  @override
  Future<AppUser?> getCurrentUser() async {
    return currentUser;
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return const Stream.empty();
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    signInEmail = email;
    signInPassword = password;
    return _gcUser;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    signUpEmail = email;
    signUpPassword = password;
    signUpDisplayName = displayName;
    signUpRole = role;
    return SignUpResult(
      email: email,
      needsEmailConfirmation: true,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    resetEmail = email;
  }

  @override
  Future<void> updatePassword({required String password}) async {
    updatedPassword = password;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}
