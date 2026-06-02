enum UserRole {
  gc('gc'),
  client('client');

  const UserRole(this.id);

  final String id;

  static UserRole? tryParse(Object? value) {
    if (value is! String) {
      return null;
    }

    for (final role in values) {
      if (role.id == value) {
        return role;
      }
    }

    return null;
  }

  static UserRole parseOrClient(Object? value) {
    return tryParse(value) ?? UserRole.client;
  }

  String get label {
    return switch (this) {
      UserRole.gc => 'Contractor',
      UserRole.client => 'Client',
    };
  }

  String get homePath {
    return switch (this) {
      UserRole.gc => '/gc/projects',
      UserRole.client => '/client/my-projects',
    };
  }
}
