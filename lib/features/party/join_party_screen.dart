import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Join screen that supports QR scanning and manual code entry.
class JoinPartyScreen extends ConsumerStatefulWidget {
  const JoinPartyScreen({super.key, this.joinCode});

  final String? joinCode;

  @override
  ConsumerState<JoinPartyScreen> createState() => _JoinPartyScreenState();
}

class _JoinPartyScreenState extends ConsumerState<JoinPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  late final ConfettiController _confettiController;

  bool _isResolving = false;
  bool _isJoining = false;
  bool _showScanner = false;
  bool _scannerLocked = false;
  dynamic _party;

  bool get _isMobileScannerSupported {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    final initialCode = widget.joinCode?.toUpperCase();
    if (initialCode != null && initialCode.isNotEmpty) {
      _codeController.text = initialCode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveCode());
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Resolves entered join code to party preview details.
  Future<void> _resolveCode() async {
    final validation = Validators.validateJoinCode(_codeController.text);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }

    setState(() {
      _isResolving = true;
      _party = null;
    });

    try {
      final party = await ref
          .read(partyControllerProvider)
          .getPartyByJoinCode(_codeController.text.trim().toUpperCase());

      if (!mounted) {
        return;
      }

      setState(() => _party = party);
      if (party == null) {
        Fluttertoast.showToast(msg: 'Party not found for this code.');
      }
    } catch (_) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Could not fetch party. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  /// Joins the currently previewed party.
  Future<void> _joinParty() async {
    if (_party == null || _isJoining) {
      return;
    }

    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Who is joining?',
        subtitle: 'Set your identity before joining this party.',
      );
    }

    final user = ref.read(sessionProvider);
    if (user == null) {
      return;
    }

    setState(() => _isJoining = true);

    try {
      final detail = await ref.read(partyControllerProvider).joinParty(
            joinCode: _party.joinCode,
            user: user,
          );

      if (detail == null) {
        Fluttertoast.showToast(msg: 'Could not join party.');
        return;
      }

      _confettiController.play();
      ref.invalidate(partiesProvider);
      ref.invalidate(myPartiesProvider);

      if (mounted) {
        context.go('/party/${_party.joinCode}');
      }
    } catch (_) {
      Fluttertoast.showToast(msg: 'Could not join party. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  /// Parses QR payload and tries to resolve a valid 6-char code.
  Future<void> _handleScan(String payload) async {
    if (_scannerLocked) {
      return;
    }

    final match = RegExp(r'([A-Z0-9]{6})$').firstMatch(payload.toUpperCase());
    final code = match?.group(1);
    if (code == null) {
      return;
    }

    _scannerLocked = true;
    _codeController.text = code;
    await _resolveCode();
    _scannerLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Party')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  validator: Validators.validateJoinCode,
                  decoration: const InputDecoration(
                    labelText: 'Join code',
                    hintText: 'A1B2C3',
                  ),
                ),
              ),
              const Gap(10),
              FilledButton.icon(
                onPressed: _isResolving ? null : _resolveCode,
                icon: const Icon(Icons.search),
                label: const Text('Find Party'),
              ),
              const Gap(10),
              if (_isMobileScannerSupported)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showScanner = !_showScanner),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(_showScanner ? 'Hide Scanner' : 'Scan QR'),
                ),
              if (_showScanner && _isMobileScannerSupported) ...[
                const Gap(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 280,
                    child: MobileScanner(
                      onDetect: (capture) {
                        final codes = capture.barcodes;
                        if (codes.isEmpty) {
                          return;
                        }

                        final raw = codes.first.rawValue;
                        if (raw == null) {
                          return;
                        }

                        _handleScan(raw);
                      },
                    ),
                  ),
                ),
              ],
              const Gap(16),
              if (_isResolving)
                const Center(child: CircularProgressIndicator())
              else if (_party == null)
                const EmptyState(
                  title: 'No party selected',
                  subtitle: 'Scan a QR or enter a 6-character code to preview the party.',
                  icon: Icons.group_outlined,
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_party.name, style: Theme.of(context).textTheme.titleLarge),
                        const Gap(6),
                        Text('Host: ${_party.hostName}'),
                        const Gap(4),
                        Text('Code: ${_party.joinCode}'),
                        if (_party.description != null && _party.description!.isNotEmpty) ...[
                          const Gap(8),
                          Text(_party.description!),
                        ],
                        const Gap(14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isJoining ? null : _joinParty,
                            child: _isJoining
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Join Party'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF4D96FF),
              Color(0xFF6BCB77),
              Color(0xFFFFC93C),
              Color(0xFFFF6B6B),
            ],
          ),
        ],
      ),
    );
  }
}
