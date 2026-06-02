import 'app_user.dart';

class SignUpResult {
  const SignUpResult({
    required this.email,
    required this.needsEmailConfirmation,
    this.user,
  });

  final String email;
  final bool needsEmailConfirmation;
  final AppUser? user;
}
