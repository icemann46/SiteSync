import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectByIdUseCase {
  const GetProjectByIdUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Project?> call(String id) {
    return _repository.getProjectById(id);
  }
}
