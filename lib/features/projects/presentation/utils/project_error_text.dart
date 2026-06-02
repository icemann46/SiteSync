import '../../domain/errors/project_failure.dart';

String projectErrorText(Object error) {
  if (error is ProjectFailure) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
