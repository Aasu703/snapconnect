import 'package:flutter/material.dart';
import 'package:snapconnect/common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/blocs/albums_bloc.dart';
import 'package:snapconnect/features/albums/albums_controller.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Simple form screen for creating a new album.
class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isSubmitting = false;
  bool _isPrivate = false;

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

    if (context.read<SessionCubit>().state == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Album creation is tied to your profile.',
      );
    }

    final user = context.read<SessionCubit>().state;
    if (user == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final album = await sl<AlbumsController>().createAlbum(
        name: _nameController.text,
        user: user,
        isPrivate: _isPrivate,
      );

      if (context.mounted) {
        context.read<AlbumsBloc>().add(FetchAlbums());
      }
      if (!mounted) {
        return;
      }
      context.go('/album/${album.id}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.showError(
        context,
        'Could not create album. Please try again.',
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
                  const Gap(12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isPrivate,
                    onChanged: (value) => setState(() => _isPrivate = value),
                    title: const Text('Private album'),
                    subtitle: const Text(
                      'Only you can see this album. Public albums show up for everyone.',
                    ),
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
