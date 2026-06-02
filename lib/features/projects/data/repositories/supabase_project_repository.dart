import '../../domain/entities/project.dart';
import '../../domain/entities/project_input.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/supabase_projects_data_source.dart';

class SupabaseProjectRepository implements ProjectRepository {
  const SupabaseProjectRepository(this._dataSource);

  final SupabaseProjectsDataSource _dataSource;

  @override
  Future<List<Project>> getProjects() async {
    final rows = await _dataSource.fetchProjects();
    return rows.map(_projectFromRow).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final row = await _dataSource.fetchProjectById(id);
    return row == null ? null : _projectFromRow(row);
  }

  @override
  Future<Project> createProject(ProjectInput input) async {
    return _projectFromRow(await _dataSource.createProject(input));
  }

  @override
  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  }) async {
    return _projectFromRow(
      await _dataSource.updateProject(id: id, input: input),
    );
  }

  @override
  Future<void> archiveProject(String id) {
    return _dataSource.archiveProject(id);
  }
}

Project _projectFromRow(Map<String, dynamic> row) {
  return Project(
    id: '${row['id']}',
    gcId: '${row['gc_id']}',
    name: '${row['name']}',
    address: row['address'] is String ? row['address'] as String : '',
    startDate: _dateTimeOrNull(row['start_date']),
    status: ProjectStatus.parse(row['status']),
    createdAt: _dateTimeOrNull(row['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

DateTime? _dateTimeOrNull(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  return null;
}
