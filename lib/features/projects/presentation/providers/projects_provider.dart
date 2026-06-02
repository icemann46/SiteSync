import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/supabase_projects_data_source.dart';
import '../../data/repositories/supabase_project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_input.dart';
import '../../domain/errors/project_failure.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/archive_project_use_case.dart';
import '../../domain/usecases/create_project_use_case.dart';
import '../../domain/usecases/get_project_by_id_use_case.dart';
import '../../domain/usecases/get_projects_use_case.dart';
import '../../domain/usecases/update_project_use_case.dart';

part 'projects_provider.g.dart';

@riverpod
SupabaseProjectsDataSource supabaseProjectsDataSource(Ref ref) {
  return SupabaseProjectsDataSource(ref.watch(supabaseClientProvider));
}

@riverpod
ProjectRepository projectRepository(Ref ref) {
  return SupabaseProjectRepository(ref.watch(supabaseProjectsDataSourceProvider));
}

@riverpod
class ProjectsController extends _$ProjectsController {
  @override
  Future<List<Project>> build() async {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };

    if (user == null) {
      return const [];
    }

    if (user.role != UserRole.gc) {
      throw const ProjectFailure('Only contractor accounts can manage projects.');
    }

    return GetProjectsUseCase(ref.watch(projectRepositoryProvider))();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return GetProjectsUseCase(ref.read(projectRepositoryProvider))();
    });
  }

  Future<Project> createProject(ProjectInput input) async {
    final existing = _currentProjects();
    final project = await CreateProjectUseCase(ref.read(projectRepositoryProvider))(input);
    state = AsyncData([project, ...existing]);
    return project;
  }

  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  }) async {
    final existing = _currentProjects();
    final project = await UpdateProjectUseCase(ref.read(projectRepositoryProvider))(
      id: id,
      input: input,
    );
    state = AsyncData([
      for (final item in existing)
        if (item.id == project.id) project else item,
    ]);
    ref.invalidate(projectByIdProvider(id));
    return project;
  }

  Future<void> archiveProject(String id) async {
    final existing = _currentProjects();
    await ArchiveProjectUseCase(ref.read(projectRepositoryProvider))(id);
    state = AsyncData([
      for (final item in existing)
        if (item.id != id) item,
    ]);
    ref.invalidate(projectByIdProvider(id));
  }

  List<Project> _currentProjects() {
    return switch (state) {
      AsyncData(:final value) => value,
      _ => const [],
    };
  }
}

@riverpod
Future<Project?> projectById(Ref ref, String id) async {
  final projects = await ref.watch(projectsControllerProvider.future);

  for (final project in projects) {
    if (project.id == id) {
      return project;
    }
  }

  return GetProjectByIdUseCase(ref.watch(projectRepositoryProvider))(id);
}
