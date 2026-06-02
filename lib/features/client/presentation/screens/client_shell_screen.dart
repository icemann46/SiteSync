import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/utils/auth_error_text.dart';

enum ClientShellTab {
  myProjects('/client/my-projects'),
  settings('/client/settings');

  const ClientShellTab(this.path);

  final String path;
}

class ClientShellScreen extends ConsumerWidget {
  const ClientShellScreen({
    required this.activeTab,
    super.key,
  });

  final ClientShellTab activeTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('SiteSync Client'),
      ),
      body: switch (activeTab) {
        ClientShellTab.myProjects => const _PlaceholderPanel(
            icon: Icons.home_outlined,
            title: 'My Projects',
            body: 'Project visibility unlocks after client invites in Phase 3.',
          ),
        ClientShellTab.settings => _SettingsPanel(
            displayName: user?.displayName,
            email: user?.email,
          ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeTab.index,
        onDestinationSelected: (index) {
          context.go(ClientShellTab.values[index].path);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'My Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({
    required this.displayName,
    required this.email,
  });

  final String? displayName;
  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_circle_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                displayName?.isNotEmpty == true ? displayName! : 'Client account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (email?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  email!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPanel extends StatelessWidget {
  const _PlaceholderPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(authControllerProvider.notifier).signOut();
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorText(error))),
    );
  }
}
