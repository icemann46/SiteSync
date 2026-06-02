import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../providers/projects_provider.dart';
import '../utils/project_error_text.dart';
import '../utils/project_formatters.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsControllerProvider);

    return Stack(
      children: [
        projectsState.when(
        data: (projects) => _ProjectListContent(projects: projects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProjectListError(message: projectErrorText(error)),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => context.go('/gc/projects/new'),
            icon: const Icon(Icons.add),
            label: const Text('New project'),
          ),
        ),
      ],
    );
  }
}

class _ProjectListContent extends ConsumerWidget {
  const _ProjectListContent({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_open_outlined, size: 56),
              const SizedBox(height: 16),
              Text('No projects yet', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Create your first project to start tracking a build.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(projectsControllerProvider.notifier).reload();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
        itemCount: projects.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Projects',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }

          return _ProjectCard(project: projects[index - 1]);
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go('/gc/projects/${project.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(label: project.status.label),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(project.address.isEmpty ? 'No address set' : project.address),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _MetaText(
                    icon: Icons.event_outlined,
                    text: 'Start: ${formatProjectDate(project.startDate)}',
                  ),
                  _MetaText(
                    icon: Icons.add_circle_outline,
                    text: 'Created: ${formatProjectDate(project.createdAt)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

class _ProjectListError extends StatelessWidget {
  const _ProjectListError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
