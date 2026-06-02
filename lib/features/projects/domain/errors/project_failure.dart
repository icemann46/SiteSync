class ProjectFailure implements Exception {
  const ProjectFailure(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
