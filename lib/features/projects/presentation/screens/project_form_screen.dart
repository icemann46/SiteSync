import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/project_input.dart';
import '../../domain/entities/project_status.dart';
import '../providers/projects_provider.dart';
import '../utils/project_error_text.dart';
import '../utils/project_formatters.dart';

class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({
    this.projectId,
    super.key,
  });

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projectId == null) {
      return const _ProjectForm(project: null);
    }

    final projectState = ref.watch(projectByIdProvider(projectId!));
    return projectState.when(
      data: (project) {
        if (project == null) {
          return const _MissingProjectPanel();
        }
        return _ProjectForm(project: project);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorPanel(message: projectErrorText(error)),
    );
  }
}

class _ProjectForm extends ConsumerStatefulWidget {
  const _ProjectForm({required this.project});

  final Project? project;

  @override
  ConsumerState<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<_ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late ProjectStatus _status;
  DateTime? _startDate;
  var _isSubmitting = false;

  bool get _isEditing {
    return widget.project != null;
  }

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameController = TextEditingController(text: project?.name ?? '');
    _addressController = TextEditingController(text: project?.address ?? '');
    _status = project?.status == ProjectStatus.archived ? ProjectStatus.active : project?.status ?? ProjectStatus.active;
    _startDate = project?.startDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final input = ProjectInput(
      name: _nameController.text,
      address: _addressController.text,
      startDate: _startDate,
      status: _status,
    );

    try {
      final controller = ref.read(projectsControllerProvider.notifier);
      final project = _isEditing
          ? await controller.updateProject(id: widget.project!.id, input: input)
          : await controller.createProject(input);

      if (!mounted) {
        return;
      }

      context.go('/gc/projects/${project.id}');
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
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _chooseStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit project' : 'Create project';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              final project = widget.project;
                              context.go(project == null ? '/gc/projects' : '/gc/projects/${project.id}');
                            },
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Project name',
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _chooseStartDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text('Start date: ${formatProjectDate(_startDate)}'),
                ),
                if (_startDate != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _startDate = null;
                              });
                            },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear start date'),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    ProjectStatus.active,
                    ProjectStatus.pending,
                    ProjectStatus.completed,
                  ].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    );
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _status = value;
                          });
                        },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isEditing ? 'Save project' : 'Create project'),
                ),
              ],
            ),
          ),
        ),
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

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

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

String? _validateName(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return 'Enter a project name.';
  }
  return null;
}
