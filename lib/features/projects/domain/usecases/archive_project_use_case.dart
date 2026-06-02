import '../repositories/project_repository.dart';

class ArchiveProjectUseCase {
  const ArchiveProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<void> call(String id) {
    return _repository.archiveProject(id);
  }
}
