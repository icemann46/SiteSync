import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
  });

  final String id;
  final String email;
  final UserRole role;
  final String displayName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            email == other.email &&
            role == other.role &&
            displayName == other.displayName;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, role, displayName);
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, role: $role, displayName: $displayName)';
  }
}
