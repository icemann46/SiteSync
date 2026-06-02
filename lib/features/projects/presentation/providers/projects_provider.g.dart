// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseProjectsDataSource)
final supabaseProjectsDataSourceProvider =
    SupabaseProjectsDataSourceProvider._();

final class SupabaseProjectsDataSourceProvider
    extends
        $FunctionalProvider<
          SupabaseProjectsDataSource,
          SupabaseProjectsDataSource,
          SupabaseProjectsDataSource
        >
    with $Provider<SupabaseProjectsDataSource> {
  SupabaseProjectsDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseProjectsDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseProjectsDataSourceHash();

  @$internal
  @override
  $ProviderElement<SupabaseProjectsDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseProjectsDataSource create(Ref ref) {
    return supabaseProjectsDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseProjectsDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseProjectsDataSource>(value),
    );
  }
}

String _$supabaseProjectsDataSourceHash() =>
    r'9b448409f71d62cc0690110b5f74d02b9df75c18';

@ProviderFor(projectRepository)
final projectRepositoryProvider = ProjectRepositoryProvider._();

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectRepository,
          ProjectRepository,
          ProjectRepository
        >
    with $Provider<ProjectRepository> {
  ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'9be10caa1bedc024a13028026bb09a488d58a205';

@ProviderFor(ProjectsController)
final projectsControllerProvider = ProjectsControllerProvider._();

final class ProjectsControllerProvider
    extends $AsyncNotifierProvider<ProjectsController, List<Project>> {
  ProjectsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsControllerHash();

  @$internal
  @override
  ProjectsController create() => ProjectsController();
}

String _$projectsControllerHash() =>
    r'48d7a3bd16108609a61b4f100089ffa7d9a115a3';

abstract class _$ProjectsController extends $AsyncNotifier<List<Project>> {
  FutureOr<List<Project>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Project>>, List<Project>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Project>>, List<Project>>,
              AsyncValue<List<Project>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(projectById)
final projectByIdProvider = ProjectByIdFamily._();

final class ProjectByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Project?>, Project?, FutureOr<Project?>>
    with $FutureModifier<Project?>, $FutureProvider<Project?> {
  ProjectByIdProvider._({
    required ProjectByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectByIdHash();

  @override
  String toString() {
    return r'projectByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Project?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Project?> create(Ref ref) {
    final argument = this.argument as String;
    return projectById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectByIdHash() => r'76466e9a3267c1d3907ccde4410d685906b52b4a';

final class ProjectByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Project?>, String> {
  ProjectByIdFamily._()
    : super(
        retry: null,
        name: r'projectByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectByIdProvider call(String id) =>
      ProjectByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'projectByIdProvider';
}
