import 'project_status.dart';

class ProjectInput {
  const ProjectInput({
    required this.name,
    required this.address,
    required this.startDate,
    required this.status,
  });

  final String name;
  final String address;
  final DateTime? startDate;
  final ProjectStatus status;
}
