import '../entities/project.dart';
import '../entities/project_input.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project?> getProjectById(String id);

  Future<Project> createProject(ProjectInput input);

  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  });

  Future<void> archiveProject(String id);
}
