import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  Future<List<Project>> call() {
    return _repository.getProjects();
  }
}
