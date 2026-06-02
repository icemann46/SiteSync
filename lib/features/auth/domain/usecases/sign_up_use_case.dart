import '../entities/sign_up_result.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<SignUpResult> call({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }
}
