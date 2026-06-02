class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: '',
  );

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set. Please pass --dart-define-from-file.');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set. Please pass --dart-define-from-file.');
    }
  }
}
