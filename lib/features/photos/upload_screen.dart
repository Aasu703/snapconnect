import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:snapconnect/common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/blocs/albums_bloc.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/blocs/upload_bloc.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

/// Multi-photo upload screen with per-photo status and progress.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.initialAlbumId});

  final String? initialAlbumId;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  late final ConfettiController _confettiController;

  String? _selectedAlbumId;

  @override
  void initState() {
    super.initState();
    _selectedAlbumId = widget.initialAlbumId;
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AlbumsBloc>().add(FetchAlbums());
      context.read<UploadBloc>().add(UploadCheckLostData());
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
    if (context.read<SessionCubit>().state != null) {
      return;
    }

    await IdentityBottomSheet.show(
      context,
      title: 'Who is uploading?',
      subtitle: 'Set your identity before uploading photos.',
    );

    if (!context.mounted) return;
    if (context.read<SessionCubit>().state == null) {
      context.go('/');
    }
  }

  /// Starts sequential upload and updates UI with result.
  Future<void> _uploadAll() async {
    final user = context.read<SessionCubit>().state;
    final albumId = _selectedAlbumId;

    if (user == null || albumId == null) {
      return;
    }

    context.read<UploadBloc>().add(UploadAll(
      albumId: albumId, user: user, title: _titleController.text,
    ));

    // Listen to bloc changes elsewhere, or wait for state using a listener.
    // For simplicity, we just trigger it. The user will see progress on the UI.
    // If we wanted to close upon success, we should use a BlocListener around the widget.
  }

  @override
  Widget build(BuildContext context) {
    final albumsState = context.watch<AlbumsBloc>().state;
    final uploadState = context.watch<UploadBloc>().state;
    final columns = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;

    return BlocListener<UploadBloc, UploadState>(
      listenWhen: (prev, current) => prev.isUploading && !current.isUploading,
      listener: (context, state) {
        final uploaded = state.items.where((item) => item.status == UploadItemStatus.done).length;
        final failed = state.items.where((item) => item.status == UploadItemStatus.error).length;

        if (uploaded > 0 && failed == 0) {
          _confettiController.play();
          Fluttertoast.showToast(msg: 'Upload complete: $uploaded photos uploaded');
          context.read<AlbumsBloc>().add(FetchAlbums());
          if (_selectedAlbumId != null) {
            context.read<AlbumsBloc>().add(FetchAlbumPhotos(_selectedAlbumId!));
            context.go('/album/$_selectedAlbumId');
          }
        } else if (failed > 0) {
          Fluttertoast.showToast(msg: '$failed photos failed. Tap retry on failed items.');
        }
      },
      child: Scaffold(
        backgroundColor: context.appColors.screenBackground,
        appBar: AppBar(
          title: const Text(AppStrings.uploadPhotos),
          backgroundColor: context.colors.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Builder(
              builder: (context) {
                if (albumsState.isLoadingAlbums && albumsState.albums == null) {
                  return const LoadingSkeleton(columns: 1);
                }
                if (albumsState.albumsError != null && albumsState.albums == null) {
                  return EmptyState(
                    title: 'Could not load albums',
                    subtitle: albumsState.albumsError.toString(),
                    icon: Icons.error_outline,
                    actionLabel: 'Retry',
                    onAction: () => context.read<AlbumsBloc>().add(FetchAlbums()),
                  );
                }

                final albums = albumsState.albums ?? [];

                if (albums.isEmpty) {
                  if (albumsState.isLoadingAlbums) {
                    return const LoadingSkeleton(columns: 1);
                  }
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
                  Text(
                    'Choose a target album',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAlbumId,
                    items: albums
                        .map(
                          (album) => DropdownMenuItem<String>(
                            value: album.id,
                            child: Text(album.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: uploadState.isUploading
                        ? null
                        : (value) => setState(() => _selectedAlbumId = value),
                    decoration: const InputDecoration(
                      labelText: 'Select Album',
                    ),
                  ),
                  const Gap(14),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (optional)',
                      hintText: 'Applied to all selected photos',
                    ),
                  ),
                  const Gap(18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: uploadState.isUploading
                              ? null
                              : () => context.read<UploadBloc>().add(UploadPickPhotos()),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Pick Photos'),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: uploadState.isUploading
                              ? null
                              : () => context.read<UploadBloc>().add(UploadCapturePhoto()),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take Photo'),
                        ),
                      ),
                    ],
                  ),
                  const Gap(18),
                  if (uploadState.totalCount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: uploadState.totalCount == 0
                              ? 0
                              : uploadState.uploadedCount /
                                    uploadState.totalCount,
                        ),
                        const Gap(6),
                        Text(
                          '$doneCount of ${uploadState.totalCount} uploaded',
                        ),
                      ],
                    ),
                  if (uploadState.error != null) ...[
                    const Gap(10),
                    Text(
                      uploadState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const Gap(16),
                  if (uploadState.items.isNotEmpty)
                    MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: uploadState.items.length,
                      crossAxisCount: columns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        final item = uploadState.items[index];
                        return _UploadPreviewTile(
                          item: item,
                          onRemove: uploadState.isUploading
                              ? null
                              : () => context.read<UploadBloc>().add(UploadRemoveAt(index)),
                          onRetry:
                              item.status == UploadItemStatus.error &&
                                  !uploadState.isUploading
                              ? () {
                                  final user = context.read<SessionCubit>().state;
                                  final albumId = _selectedAlbumId;
                                  if (user != null && albumId != null) {
                                    context.read<UploadBloc>().add(UploadRetryItem(
                                      index: index,
                                      albumId: albumId,
                                      user: user,
                                      title: _titleController.text,
                                    ));
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                  const Gap(20),
                  FilledButton(
                    onPressed:
                        uploadState.items.isEmpty ||
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
    ),
    );
  }
}

class _UploadPreviewTile extends StatelessWidget {
  const _UploadPreviewTile({required this.item, this.onRemove, this.onRetry});

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
        children: [
          FutureBuilder<Uint8List>(
            future: item.file.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const AspectRatio(
                  aspectRatio: 1,
                  child: ColoredBox(color: Colors.black12),
                );
              }
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            },
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
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
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(999),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ),
            ),
          if (onRetry != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 48,
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
            ),
        ],
      ),
    );
  }
}
