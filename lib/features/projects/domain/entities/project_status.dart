enum ProjectStatus {
  active('active'),
  pending('pending'),
  completed('completed'),
  archived('archived');

  const ProjectStatus(this.id);

  final String id;

  static ProjectStatus parse(Object? value) {
    if (value is String) {
      for (final status in values) {
        if (status.id == value) {
          return status;
        }
      }
    }

    return ProjectStatus.active;
  }

  String get label {
    return switch (this) {
      ProjectStatus.active => 'Active',
      ProjectStatus.pending => 'Pending',
      ProjectStatus.completed => 'Completed',
      ProjectStatus.archived => 'Archived',
    };
  }
}
