import 'dart:convert';

import '../entities/user_role.dart';

class JwtRoleParser {
  const JwtRoleParser._();

  static UserRole? roleFromAccessToken(String accessToken) {
    final claims = claimsFromAccessToken(accessToken);
    final appMetadata = claims['app_metadata'];

    if (appMetadata is Map<String, dynamic>) {
      return UserRole.tryParse(appMetadata['site_sync_role']);
    }

    if (appMetadata is Map) {
      return UserRole.tryParse(appMetadata['site_sync_role']);
    }

    return null;
  }

  static Map<String, dynamic> claimsFromAccessToken(String accessToken) {
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      return const {};
    }

    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } on FormatException {
      return const {};
    }

    return const {};
  }
}
