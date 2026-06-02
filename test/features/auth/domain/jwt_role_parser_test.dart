import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/features/auth/domain/entities/user_role.dart';
import 'package:site_sync/features/auth/domain/services/jwt_role_parser.dart';

void main() {
  group('JwtRoleParser', () {
    test('reads SiteSync role from app_metadata.site_sync_role', () {
      final token = _jwt({
        'app_metadata': {'site_sync_role': 'gc'},
      });

      expect(JwtRoleParser.roleFromAccessToken(token), UserRole.gc);
    });

    test('returns null for missing role claim', () {
      final token = _jwt({'app_metadata': <String, Object?>{}});

      expect(JwtRoleParser.roleFromAccessToken(token), isNull);
    });

    test('returns null for invalid role claim', () {
      final token = _jwt({
        'app_metadata': {'site_sync_role': 'admin'},
      });

      expect(JwtRoleParser.roleFromAccessToken(token), isNull);
    });

    test('returns empty claims for malformed token', () {
      expect(JwtRoleParser.claimsFromAccessToken('not-a-jwt'), isEmpty);
    });
  });
}

String _jwt(Map<String, Object?> payload) {
  final encodedPayload = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');

  return 'header.$encodedPayload.signature';
}
