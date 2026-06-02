import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../domain/entities/user_role.dart';

class SupabaseAuthDataSource {
  const SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  Session? get currentSession {
    return _client.auth.currentSession;
  }

  Stream<Session?> watchSession() {
    return _client.auth.onAuthStateChange.map((state) => state.session);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectUrlOrNull,
      data: {
        'display_name': displayName,
        'site_sync_role': role.id,
      },
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: _redirectUrlOrNull,
    );
  }

  Future<void> updatePassword({required String password}) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  String? get _redirectUrlOrNull {
    return EnvConfig.authRedirectUrl.isEmpty ? null : EnvConfig.authRedirectUrl;
  }
}
