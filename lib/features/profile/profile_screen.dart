import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Profile screen for identity, preferences, and user stats.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Prompts to edit profile name.
  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final user = ref.read(sessionProvider);
    if (user == null) {
      return;
    }

    final controller = TextEditingController(text: user.name);

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit name'),
          content: TextFormField(
            controller: controller,
            autofocus: true,
            validator: Validators.validateName,
            decoration: const InputDecoration(hintText: 'Your display name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null || Validators.validateName(name) != null) {
      return;
    }

    final updated = await ref.read(profileControllerProvider).updateName(user, name);
    await ref.read(sessionProvider.notifier).updateUser(updated);
    ref.invalidate(profileProvider);
  }

  /// Prompts to add email for cross-device restoration.
  Future<void> _addEmail(BuildContext context, WidgetRef ref) async {
    final user = ref.read(sessionProvider);
    if (user == null) {
      return;
    }

    final controller = TextEditingController(text: user.email ?? '');

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add email'),
          content: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'you@example.com'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (email == null || Validators.validateOptionalEmail(email) != null) {
      return;
    }

    final updated = await ref.read(profileControllerProvider).addEmail(user, email);
    await ref.read(sessionProvider.notifier).updateUser(updated);
    ref.invalidate(profileProvider);
  }

  /// Clears current session and profile data.
  Future<void> _logout(WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).clear();
    ref.invalidate(profileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final profileStats = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: EmptyState(
          title: 'No identity set',
          subtitle: 'Add your name to upload and react as yourself.',
          icon: Icons.person_outline,
          actionLabel: 'Set identity',
          onAction: () => IdentityBottomSheet.show(context),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                AvatarWidget(name: user.name, colorHex: user.avatarColor, size: 84),
                const Gap(12),
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                const Gap(6),
                Text(user.email ?? 'No email added', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Gap(24),
          profileStats.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const Text('Could not load stats'),
            data: (stats) {
              return Row(
                children: [
                  _StatCard(label: 'Photos', value: '${stats.photosUploaded}'),
                  const Gap(10),
                  _StatCard(label: 'Albums', value: '${stats.albumsCreated}'),
                  const Gap(10),
                  _StatCard(label: 'Parties', value: '${stats.partiesJoined}'),
                ],
              );
            },
          ),
          const Gap(24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit name'),
            onTap: () => _editName(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alternate_email),
            title: Text(user.email == null ? 'Add email' : 'Update email'),
            onTap: () => _addEmail(context, ref),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Gap(8),
          OutlinedButton.icon(
            onPressed: () => _logout(ref),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const Gap(28),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data == null
                  ? '...'
                  : '${snapshot.data!.version} (${snapshot.data!.buildNumber})';
              return Center(
                child: Text(
                  'App version $version',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const Gap(2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
