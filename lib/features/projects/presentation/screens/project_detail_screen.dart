import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../providers/projects_provider.dart';
import '../utils/project_error_text.dart';
import '../utils/project_formatters.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectByIdProvider(projectId));

    return projectState.when(
      data: (project) {
        if (project == null) {
          return const _MissingProjectPanel();
        }
        return _ProjectDetail(project: project);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _DetailError(message: projectErrorText(error)),
    );
  }
}

class _ProjectDetail extends ConsumerStatefulWidget {
  const _ProjectDetail({required this.project});

  final Project project;

  @override
  ConsumerState<_ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends ConsumerState<_ProjectDetail> {
  var _isArchiving = false;

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive project?'),
          content: Text('${widget.project.name} will be removed from the active project list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isArchiving = true;
    });

    try {
      await ref.read(projectsControllerProvider.notifier).archiveProject(widget.project.id);
      if (!mounted) {
        return;
      }
      context.go('/gc/projects');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(projectErrorText(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isArchiving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isArchiving ? null : () => context.go('/gc/projects'),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: _isArchiving ? null : () => context.go('/gc/projects/${project.id}/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit project',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: project.address.isEmpty ? 'No address set' : project.address,
              ),
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'Start date',
                value: formatProjectDate(project.startDate),
              ),
              _DetailRow(
                icon: Icons.flag_outlined,
                label: 'Status',
                value: project.status.label,
              ),
              _DetailRow(
                icon: Icons.add_circle_outline,
                label: 'Created',
                value: formatProjectDate(project.createdAt),
              ),
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Project detail content will expand in later phases.'),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isArchiving ? null : _archive,
                icon: _isArchiving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.archive_outlined),
                label: const Text('Archive project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingProjectPanel extends StatelessWidget {
  const _MissingProjectPanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 56),
            const SizedBox(height: 16),
            Text('Project not found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/gc/projects'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to projects'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message),
      ),
    );
  }
}
