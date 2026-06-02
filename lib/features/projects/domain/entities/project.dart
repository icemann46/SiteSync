import 'project_status.dart';

class Project {
  const Project({
    required this.id,
    required this.gcId,
    required this.name,
    required this.address,
    required this.startDate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String gcId;
  final String name;
  final String address;
  final DateTime? startDate;
  final ProjectStatus status;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Project &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            gcId == other.gcId &&
            name == other.name &&
            address == other.address &&
            startDate == other.startDate &&
            status == other.status &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, gcId, name, address, startDate, status, createdAt);
  }
}
