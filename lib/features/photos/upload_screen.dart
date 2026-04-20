import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';

/// Multi-photo upload screen with per-photo status and progress.
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key, this.initialAlbumId});

  final String? initialAlbumId;

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _titleController = TextEditingController();
  late final ConfettiController _confettiController;

  String? _selectedAlbumId;

  @override
  void initState() {
    super.initState();
    _selectedAlbumId = widget.initialAlbumId;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureIdentity();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Enforces identity before upload actions.
  Future<void> _ensureIdentity() async {
    if (ref.read(sessionProvider) != null) {
      return;
    }

    await IdentityBottomSheet.show(
      context,
      title: 'Who is uploading?',
      subtitle: 'Set your identity before uploading photos.',
    );

    if (ref.read(sessionProvider) == null && mounted) {
      context.go('/');
    }
  }

  /// Starts sequential upload and updates UI with result.
  Future<void> _uploadAll() async {
    final user = ref.read(sessionProvider);
    final albumId = _selectedAlbumId;

    if (user == null || albumId == null) {
      return;
    }

    await ref.read(uploadProvider.notifier).uploadAll(
          albumId: albumId,
          user: user,
          title: _titleController.text,
        );

    final state = ref.read(uploadProvider);
    final uploaded = state.items.where((item) => item.status == UploadItemStatus.done).length;
    final failed = state.items.where((item) => item.status == UploadItemStatus.error).length;

    if (uploaded > 0) {
      _confettiController.play();
      Fluttertoast.showToast(msg: 'Upload complete: $uploaded photos uploaded');
      ref.invalidate(albumsProvider);
      ref.invalidate(albumDetailProvider(albumId));
      if (mounted) {
        context.go('/album/$albumId');
      }
    }

    if (failed > 0) {
      Fluttertoast.showToast(msg: '$failed photos failed. Tap retry on failed items.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final uploadState = ref.watch(uploadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Photos')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          albumsAsync.when(
            loading: () => const LoadingSkeleton(columns: 1),
            error: (error, _) => EmptyState(
              title: 'Could not load albums',
              subtitle: error.toString(),
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(albumsProvider),
            ),
            data: (albums) {
              if (albums.isEmpty) {
                return EmptyState(
                  title: 'Create an album first',
                  subtitle: 'Uploads need a target album.',
                  icon: Icons.photo_album_outlined,
                  actionLabel: 'Create Album',
                  onAction: () => context.push('/album/create'),
                );
              }

              _selectedAlbumId ??= albums.first.id;

              final doneCount = uploadState.items
                  .where((item) => item.status == UploadItemStatus.done)
                  .length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAlbumId,
                    items: albums
                        .map(
                          (album) => DropdownMenuItem<String>(
                            value: album.id,
                            child: Text(album.name),
                          ),
                        )
                        .toList(),
                    onChanged: uploadState.isUploading
                        ? null
                        : (value) => setState(() => _selectedAlbumId = value),
                    decoration: const InputDecoration(labelText: 'Select Album'),
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (optional)',
                      hintText: 'Applied to all selected photos',
                    ),
                  ),
                  const Gap(16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: uploadState.isUploading
                            ? null
                            : () => ref.read(uploadProvider.notifier).pickPhotos(),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Pick Photos'),
                      ),
                      OutlinedButton.icon(
                        onPressed: uploadState.isUploading
                            ? null
                            : () => ref.read(uploadProvider.notifier).capturePhoto(),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take Photo'),
                      ),
                    ],
                  ),
                  const Gap(16),
                  if (uploadState.totalCount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: uploadState.totalCount == 0
                              ? 0
                              : uploadState.uploadedCount / uploadState.totalCount,
                        ),
                        const Gap(6),
                        Text('$doneCount of ${uploadState.totalCount} uploaded'),
                      ],
                    ),
                  if (uploadState.error != null) ...[
                    const Gap(10),
                    Text(
                      uploadState.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const Gap(16),
                  if (uploadState.items.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: uploadState.items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = uploadState.items[index];
                        return _UploadPreviewTile(
                          item: item,
                          onRemove: uploadState.isUploading
                              ? null
                              : () => ref.read(uploadProvider.notifier).removeAt(index),
                          onRetry: item.status == UploadItemStatus.error && !uploadState.isUploading
                              ? () {
                                  final user = ref.read(sessionProvider);
                                  final albumId = _selectedAlbumId;
                                  if (user != null && albumId != null) {
                                    ref.read(uploadProvider.notifier).retryItem(
                                          index: index,
                                          albumId: albumId,
                                          user: user,
                                          title: _titleController.text,
                                        );
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                  const Gap(20),
                  FilledButton(
                    onPressed: uploadState.items.isEmpty ||
                            _selectedAlbumId == null ||
                            uploadState.isUploading
                        ? null
                        : _uploadAll,
                    child: Text('Upload ${uploadState.items.length} Photos'),
                  ),
                ],
              );
            },
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

class _UploadPreviewTile extends StatelessWidget {
  const _UploadPreviewTile({
    required this.item,
    this.onRemove,
    this.onRetry,
  });

  final UploadItem item;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    IconData statusIcon;

    switch (item.status) {
      case UploadItemStatus.pending:
        borderColor = Colors.grey;
        statusIcon = Icons.schedule;
        break;
      case UploadItemStatus.uploading:
        borderColor = Colors.blue;
        statusIcon = Icons.cloud_upload;
        break;
      case UploadItemStatus.done:
        borderColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case UploadItemStatus.error:
        borderColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List>(
            future: item.file.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(color: Colors.black12);
              }
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(statusIcon, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              left: 6,
              top: 6,
              child: InkWell(
                onTap: onRemove,
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          if (onRetry != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
