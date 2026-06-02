import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/features/projects/domain/entities/project.dart';
import 'package:site_sync/features/projects/domain/entities/project_input.dart';
import 'package:site_sync/features/projects/domain/entities/project_status.dart';
import 'package:site_sync/features/projects/domain/repositories/project_repository.dart';
import 'package:site_sync/features/projects/domain/usecases/archive_project_use_case.dart';
import 'package:site_sync/features/projects/domain/usecases/create_project_use_case.dart';
import 'package:site_sync/features/projects/domain/usecases/get_project_by_id_use_case.dart';
import 'package:site_sync/features/projects/domain/usecases/get_projects_use_case.dart';
import 'package:site_sync/features/projects/domain/usecases/update_project_use_case.dart';

void main() {
  group('project use cases', () {
    late _RecordingProjectRepository repository;

    setUp(() {
      repository = _RecordingProjectRepository();
    });

    test('get projects delegates to repository', () async {
      final projects = await GetProjectsUseCase(repository)();

      expect(projects, [_project]);
      expect(repository.getProjectsCalled, isTrue);
    });

    test('get project by id delegates to repository', () async {
      final project = await GetProjectByIdUseCase(repository)('project-1');

      expect(project, _project);
      expect(repository.lastProjectId, 'project-1');
    });

    test('create project delegates project input', () async {
      final input = ProjectInput(
        name: 'New build',
        address: '45 Oak Ave',
        startDate: DateTime(2026, 7, 1),
        status: ProjectStatus.pending,
      );

      final project = await CreateProjectUseCase(repository)(input);

      expect(project, _project);
      expect(repository.createdInput, input);
    });

    test('update project delegates id and input', () async {
      final input = ProjectInput(
        name: 'Updated build',
        address: '',
        startDate: null,
        status: ProjectStatus.completed,
      );

      final project = await UpdateProjectUseCase(repository)(
        id: 'project-1',
        input: input,
      );

      expect(project, _project);
      expect(repository.lastProjectId, 'project-1');
      expect(repository.updatedInput, input);
    });

    test('archive project delegates id', () async {
      await ArchiveProjectUseCase(repository)('project-1');

      expect(repository.archivedProjectId, 'project-1');
    });
  });
}

final _project = Project(
  id: 'project-1',
  gcId: 'gc-1',
  name: 'Kitchen Remodel',
  address: '12 Main St',
  startDate: DateTime(2026, 7, 1),
  status: ProjectStatus.active,
  createdAt: DateTime(2026, 6, 2),
);

class _RecordingProjectRepository implements ProjectRepository {
  bool getProjectsCalled = false;
  String? lastProjectId;
  ProjectInput? createdInput;
  ProjectInput? updatedInput;
  String? archivedProjectId;

  @override
  Future<List<Project>> getProjects() async {
    getProjectsCalled = true;
    return [_project];
  }

  @override
  Future<Project?> getProjectById(String id) async {
    lastProjectId = id;
    return _project;
  }

  @override
  Future<Project> createProject(ProjectInput input) async {
    createdInput = input;
    return _project;
  }

  @override
  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  }) async {
    lastProjectId = id;
    updatedInput = input;
    return _project;
  }

  @override
  Future<void> archiveProject(String id) async {
    archivedProjectId = id;
  }
}
