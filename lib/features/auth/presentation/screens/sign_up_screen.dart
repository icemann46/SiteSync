import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_role.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_error_text.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _role = UserRole.gc;
  var _isSubmitting = false;
  String? _confirmationEmail;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _confirmationEmail = null;
    });

    try {
      final result = await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _displayNameController.text,
            role: _role,
          );

      if (!mounted) {
        return;
      }

      if (result.needsEmailConfirmation) {
        setState(() {
          _confirmationEmail = result.email;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorText(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create your SiteSync account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the role that matches how you will use this workspace.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.gc,
                          label: Text("I'm a Contractor"),
                          icon: Icon(Icons.construction_outlined),
                        ),
                        ButtonSegment(
                          value: UserRole.client,
                          label: Text("I'm a Client"),
                          icon: Icon(Icons.home_outlined),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: _isSubmitting
                          ? null
                          : (selection) {
                              setState(() {
                                _role = selection.single;
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateDisplayName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_confirmationEmail != null) ...[
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Check $_confirmationEmail for a confirmation link before logging in.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                    TextButton(
                      onPressed: _isSubmitting ? null : () => context.go('/login'),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateDisplayName(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return 'Enter your display name.';
  }
  return null;
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email.';
  }
  if (!email.contains('@')) {
    return 'Enter a valid email.';
  }
  return null;
}

String? _validatePassword(String? value) {
  if ((value ?? '').length < 6) {
    return 'Use at least 6 characters.';
  }
  return null;
}
