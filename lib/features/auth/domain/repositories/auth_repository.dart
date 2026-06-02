import '../entities/app_user.dart';
import '../entities/sign_up_result.dart';
import '../entities/user_role.dart';

abstract interface class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> watchAuthState();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String password});

  Future<void> signOut();
}
