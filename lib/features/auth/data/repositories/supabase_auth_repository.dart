import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/jwt_role_parser.dart';
import '../datasources/supabase_auth_datasource.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._dataSource);

  final SupabaseAuthDataSource _dataSource;

  @override
  Future<AppUser?> getCurrentUser() async {
    return _appUserFromSession(_dataSource.currentSession);
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _dataSource.watchSession().map(_appUserFromSession);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.signIn(
      email: email.trim(),
      password: password,
    );
    final appUser = _appUserFromSession(response.session);

    if (appUser == null) {
      throw const AuthFailure('Sign in succeeded but no active session was returned.');
    }

    return appUser;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim();
    final response = await _dataSource.signUp(
      email: normalizedEmail,
      password: password,
      displayName: displayName.trim(),
      role: role,
    );

    return SignUpResult(
      email: normalizedEmail,
      needsEmailConfirmation: response.session == null,
      user: _appUserFromSession(response.session),
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _dataSource.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> updatePassword({required String password}) {
    return _dataSource.updatePassword(password: password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  AppUser? _appUserFromSession(Session? session) {
    if (session == null) {
      return null;
    }

    final user = session.user;
    final userMetadata = user.userMetadata ?? const <String, dynamic>{};
    final tokenRole = JwtRoleParser.roleFromAccessToken(session.accessToken);
    final metadataRole = UserRole.tryParse(userMetadata['site_sync_role']);
    final role = tokenRole ?? metadataRole ?? UserRole.client;
    final displayName = userMetadata['display_name'];

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      role: role,
      displayName: displayName is String ? displayName : '',
    );
  }
}
