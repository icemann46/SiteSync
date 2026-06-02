import '../entities/project.dart';
import '../entities/project_input.dart';
import '../repositories/project_repository.dart';

class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Project> call({
    required String id,
    required ProjectInput input,
  }) {
    return _repository.updateProject(id: id, input: input);
  }
}
