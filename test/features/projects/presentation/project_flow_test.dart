import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_sync/features/auth/domain/entities/app_user.dart';
import 'package:site_sync/features/auth/domain/entities/sign_up_result.dart';
import 'package:site_sync/features/auth/domain/entities/user_role.dart';
import 'package:site_sync/features/auth/domain/repositories/auth_repository.dart';
import 'package:site_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:site_sync/features/projects/domain/entities/project.dart';
import 'package:site_sync/features/projects/domain/entities/project_input.dart';
import 'package:site_sync/features/projects/domain/entities/project_status.dart';
import 'package:site_sync/features/projects/domain/repositories/project_repository.dart';
import 'package:site_sync/features/projects/presentation/providers/projects_provider.dart';
import 'package:site_sync/main.dart';

void main() {
  testWidgets('GC can view project cards and open detail placeholder', (tester) async {
    final projectRepository = _FakeProjectRepository(projects: [_project]);

    await tester.pumpWidget(_app(projectRepository));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Remodel'), findsOneWidget);
    expect(find.text('12 Main St'), findsOneWidget);

    await tester.tap(find.text('Kitchen Remodel'));
    await tester.pumpAndSettle();

    expect(find.text('Project detail content will expand in later phases.'), findsOneWidget);
  });

  testWidgets('GC can create a project from the project list', (tester) async {
    final projectRepository = _FakeProjectRepository();

    await tester.pumpWidget(_app(projectRepository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New project'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Basement Finish');
    await tester.enterText(find.byType(TextFormField).at(1), '88 Pine Rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Create project'));
    await tester.pumpAndSettle();

    expect(projectRepository.createdInputs.single.name, 'Basement Finish');
    expect(projectRepository.createdInputs.single.address, '88 Pine Rd');
    expect(find.text('Project detail content will expand in later phases.'), findsOneWidget);
  });

  testWidgets('GC can edit a project', (tester) async {
    final projectRepository = _FakeProjectRepository(projects: [_project]);

    await tester.pumpWidget(_app(projectRepository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kitchen Remodel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Kitchen Remodel Updated');
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();

    expect(projectRepository.updatedInputs.single.name, 'Kitchen Remodel Updated');
    expect(find.text('Kitchen Remodel Updated'), findsOneWidget);
  });

  testWidgets('GC can archive a project', (tester) async {
    final projectRepository = _FakeProjectRepository(projects: [_project]);

    await tester.pumpWidget(_app(projectRepository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kitchen Remodel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive project'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();

    expect(projectRepository.archivedProjectIds, ['project-1']);
    expect(find.text('Kitchen Remodel'), findsNothing);
  });
}

Widget _app(_FakeProjectRepository projectRepository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      projectRepositoryProvider.overrideWithValue(projectRepository),
    ],
    child: const SiteSyncApp(),
  );
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

const _gcUser = AppUser(
  id: 'gc-1',
  email: 'gc@example.com',
  role: UserRole.gc,
  displayName: 'General Contractor',
);

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Future<AppUser?> getCurrentUser() async {
    return _gcUser;
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    return _gcUser;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword({required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}

class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository({List<Project> projects = const []}) : _projects = [...projects];

  final List<Project> _projects;
  final List<ProjectInput> createdInputs = [];
  final List<ProjectInput> updatedInputs = [];
  final List<String> archivedProjectIds = [];

  @override
  Future<List<Project>> getProjects() async {
    return _projects.where((project) => project.status != ProjectStatus.archived).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    for (final project in _projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }

  @override
  Future<Project> createProject(ProjectInput input) async {
    createdInputs.add(input);
    final project = Project(
      id: 'created-${createdInputs.length}',
      gcId: 'gc-1',
      name: input.name,
      address: input.address,
      startDate: input.startDate,
      status: input.status,
      createdAt: DateTime(2026, 6, 2),
    );
    _projects.insert(0, project);
    return project;
  }

  @override
  Future<Project> updateProject({
    required String id,
    required ProjectInput input,
  }) async {
    updatedInputs.add(input);
    final index = _projects.indexWhere((project) => project.id == id);
    final updated = Project(
      id: id,
      gcId: 'gc-1',
      name: input.name,
      address: input.address,
      startDate: input.startDate,
      status: input.status,
      createdAt: _projects[index].createdAt,
    );
    _projects[index] = updated;
    return updated;
  }

  @override
  Future<void> archiveProject(String id) async {
    archivedProjectIds.add(id);
    _projects.removeWhere((project) => project.id == id);
  }
}
