import '../entities/project.dart';
import '../entities/project_input.dart';
import '../repositories/project_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Project> call(ProjectInput input) {
    return _repository.createProject(input);
  }
}
