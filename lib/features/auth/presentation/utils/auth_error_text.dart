import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/errors/auth_failure.dart';

String authErrorText(Object error) {
  if (error is AuthFailure) {
    return error.message;
  }

  if (error is AuthException) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
