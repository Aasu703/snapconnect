import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Simple form screen for creating a new album.
class CreateAlbumScreen extends ConsumerStatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  ConsumerState<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends ConsumerState<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Ensures identity and creates an album.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Album creation is tied to your profile.',
      );
    }

    final user = ref.read(sessionProvider);
    if (user == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final album = await ref
          .read(albumsControllerProvider)
          .createAlbum(name: _nameController.text, user: user);

      ref.invalidate(albumsProvider);
      if (!mounted) {
        return;
      }
      context.go('/album/${album.id}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create album. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Album')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Album name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Summer 2026'),
                    validator: Validators.validateName,
                  ),
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Album'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
