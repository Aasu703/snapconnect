import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/live_badge.dart';
import 'package:snapconnect/widgets/photo_grid.dart';
import 'package:snapconnect/widgets/reaction_bar.dart';

/// Party details screen showing QR join flow and live photo feed.
class PartyDetailScreen extends ConsumerStatefulWidget {
  const PartyDetailScreen({super.key, required this.joinCode});

  final String joinCode;

  @override
  ConsumerState<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends ConsumerState<PartyDetailScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(AppConstants.partyRefreshInterval, (_) {
      ref.invalidate(partyDetailProvider(widget.joinCode));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(partyDetailProvider(widget.joinCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Details'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(partyDetailProvider(widget.joinCode)),
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            title: 'Could not load party',
            subtitle: error.toString(),
            icon: Icons.error_outline,
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(partyDetailProvider(widget.joinCode)),
          ),
          data: (detail) {
            if (detail == null) {
              return const EmptyState(
                title: 'Party not found',
                subtitle: 'This join code is invalid or the party is inactive.',
                icon: Icons.group_off_outlined,
              );
            }

            final party = detail.party;
            final joinUrl = '${AppConstants.webJoinBaseUrl}/join/${party.joinCode}';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(party.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const LiveBadge(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    AvatarWidget(name: party.hostName, size: 36),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Hosted by ${party.hostName}')),
                    Text('${detail.members.length} members'),
                  ],
                ),
                const SizedBox(height: 14),
                if (detail.members.isNotEmpty)
                  SizedBox(
                    height: 34,
                    child: Stack(
                      children: [
                        for (var i = 0; i < detail.members.length.clamp(0, 6); i++)
                          Positioned(
                            left: i * 22,
                            child: AvatarWidget(name: detail.members[i].userName, size: 32),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: joinUrl,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Share.share(joinUrl),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'QR download tip: take screenshot or share the join URL.',
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download QR'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Live Photos', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: PhotoGrid(
                    photos: detail.photos,
                    onPhotoTap: (photo) => context.push('/photo/${photo.id}?albumId=${photo.albumId}'),
                    footerBuilder: (photo) => ReactionBar(photoId: photo.id),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: detailAsync.maybeWhen(
        data: (detail) {
          if (detail == null) {
            return null;
          }
          return FloatingActionButton(
            onPressed: () => context.push('/upload?albumId=${detail.party.albumId}'),
            child: const Icon(Icons.camera_alt_rounded),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
