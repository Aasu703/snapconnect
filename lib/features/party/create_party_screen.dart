import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/blocs/party_bloc.dart';
import 'package:snapconnect/features/party/party_controller.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Form screen used to create a new party event.
class CreatePartyScreen extends StatefulWidget {
  const CreatePartyScreen({super.key});

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureIdentity();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Enforces identity for party host actions.
  Future<void> _ensureIdentity() async {
    if (context.read<SessionCubit>().state != null) {
      return;
    }

    await IdentityBottomSheet.show(
      context,
      title: 'Host identity required',
      subtitle: 'Set your identity to create and host a party.',
    );

    if (context.read<SessionCubit>().state == null && mounted) {
      context.go('/party');
    }
  }

  /// Validates and submits party creation.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    final user = context.read<SessionCubit>().state;
    if (user == null) {
      await _ensureIdentity();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final party = await sl<PartyController>()
          .createParty(
            name: _nameController.text,
            description: _descriptionController.text,
            host: user,
          );

      if (context.mounted) {
        context.read<PartyBloc>().add(FetchParties());
        context.read<PartyBloc>().add(FetchMyParties(user));
      }
      if (!mounted) {
        return;
      }
      context.go('/party/${party.joinCode}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create party. Please try again.'),
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
      appBar: AppBar(title: const Text('Create Party')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Party name',
                      hintText: 'Aarav Birthday Night',
                    ),
                    validator: Validators.validateName,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Pool party, bring your best dance moves!',
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
                          : const Text('Create Party'),
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
