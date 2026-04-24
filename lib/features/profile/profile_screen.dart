import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';

/// Profile screen that always renders a visible state.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileScreen mounted');
    final user = ref.read(sessionProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
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

    final updated = await ref
        .read(profileControllerProvider)
        .updateName(user, name);
    await ref.read(sessionProvider.notifier).updateUser(updated);
    debugPrint('ProfileScreen: updated name to ${updated.name}');
  }

  Future<void> _addEmail() async {
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

    final updated = await ref
        .read(profileControllerProvider)
        .addEmail(user, email);
    await ref.read(sessionProvider.notifier).updateUser(updated);
    debugPrint('ProfileScreen: updated email to ${updated.email}');
  }

  Future<void> _saveIdentity() async {
    final nameError = Validators.validateName(_nameController.text);
    final emailError = Validators.validateOptionalEmail(_emailController.text);

    if (nameError != null || emailError != null) {
      if (!mounted) {
        return;
      }

      final message =
          nameError ?? emailError ?? 'Please fix the highlighted fields.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await ref
          .read(onboardingControllerProvider)
          .createOrRestoreUser(
            name: _nameController.text,
            email: _emailController.text,
          );
      await ref.read(sessionProvider.notifier).setUser(user);
      debugPrint('ProfileScreen: identity created/restored for ${user.id}');
    } catch (e, stack) {
      debugPrint('ProfileScreen identity error: $e');
      debugPrint('ProfileScreen identity stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not set up your profile.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _logout() async {
    await ref.read(sessionProvider.notifier).clear();
    debugPrint('ProfileScreen: user logged out');
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileScreen build called');
    final user = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 72,
                    color: Color(0xFF4D96FF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Set up your profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your name so albums, parties, and uploads show who you are.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Alex Johnson',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      hintText: 'alex@example.com',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _saveIdentity,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                AvatarWidget(
                  name: user.name,
                  colorHex: user.avatarColor,
                  size: 84,
                ),
                const Gap(12),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Gap(6),
                Text(
                  user.email ?? 'No email set',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Gap(18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E5E8)),
            ),
            child: const Text(
              'Profile is available instantly from local session data.\n'
              'Stats sync can be added separately if needed.',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const Gap(20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit name'),
            onTap: _editName,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alternate_email),
            title: Text(user.email == null ? 'Add email' : 'Update email'),
            onTap: _addEmail,
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
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
