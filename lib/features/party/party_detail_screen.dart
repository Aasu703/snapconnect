import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:snapconnect/core/blocs/party_bloc.dart';
import 'package:snapconnect/core/utils/party_invite_link.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/live_badge.dart';
import 'package:snapconnect/widgets/photo_grid.dart';
import 'package:snapconnect/widgets/reaction_picker_controller.dart';

/// Party details screen showing QR join flow and live photo feed.
class PartyDetailScreen extends StatefulWidget {
  const PartyDetailScreen({super.key, required this.joinCode});

  final String joinCode;

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen>
    with ReactionPickerController<PartyDetailScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartyBloc>().add(FetchPartyDetail(widget.joinCode));
    });

    _refreshTimer = Timer.periodic(AppConstants.partyRefreshInterval, (_) {
      if (mounted) {
        context.read<PartyBloc>().add(FetchPartyDetail(widget.joinCode));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partyState = context.watch<PartyBloc>().state;

    return Stack(
      children: [
        _buildScaffold(context, partyState),
        buildReactionOverlay(),
      ],
    );
  }

  Widget _buildScaffold(BuildContext context, PartyState partyState) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Details')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PartyBloc>().add(FetchPartyDetail(widget.joinCode));
        },
        child: Builder(
          builder: (context) {
            if (partyState.isLoadingPartyDetail && partyState.partyDetail == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (partyState.partyDetailError != null && partyState.partyDetail == null) {
              return EmptyState(
                title: 'Could not load party',
                subtitle: partyState.partyDetailError.toString(),
                icon: Icons.error_outline,
                actionLabel: 'Retry',
                onAction: () =>
                    context.read<PartyBloc>().add(FetchPartyDetail(widget.joinCode)),
              );
            }

            final detail = partyState.partyDetail;
            if (detail == null && !partyState.isLoadingPartyDetail) {
              return const EmptyState(
                title: 'Party not found',
                subtitle: 'This join code is invalid or the party is inactive.',
                icon: Icons.group_off_outlined,
              );
            }

            if (detail == null) {
              return const SizedBox.shrink();
            }

            final party = detail.party;
            // QR encodes the deep link so a scan opens the app on the join
            // screen; the share sheet sends the https form so recipients
            // without the app installed still have somewhere to land.
            final joinDeepLink = PartyInviteLink.deepLinkFor(party.joinCode);
            final joinWebLink = PartyInviteLink.webLinkFor(party.joinCode);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  party.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
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
                        for (
                          var i = 0;
                          i < detail.members.length.clamp(0, 6);
                          i++
                        )
                          Positioned(
                            left: i * 22,
                            child: AvatarWidget(
                              name: detail.members[i].userName,
                              size: 32,
                            ),
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
                      data: joinDeepLink,
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
                      onPressed: () => Share.share(
                        'Join "${party.fullName}" on SnapConnect!\n'
                        '$joinWebLink\n'
                        'Or enter code: ${party.joinCode}',
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg:
                              'QR download tip: take screenshot or share the join URL.',
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download QR'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Live Photos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: PhotoGrid(
                    photos: detail.photos,
                    onPhotoTap: (photo) => context.push(
                      '/photo/${photo.id}?albumId=${photo.albumId}',
                    ),
                    onReactionLongPressStart: (photo, details) =>
                        onReactionLongPressStart(photo.id, details),
                    onReactionLongPressMoveUpdate: (_, details) =>
                        onReactionLongPressMove(details),
                    onReactionLongPressEnd: (_, details) =>
                        onReactionLongPressEnd(details),
                    onReactionLongPressCancel: (_) =>
                        onReactionLongPressCancel(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final detail = context.watch<PartyBloc>().state.partyDetail;
          if (detail == null) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () =>
                context.push('/upload?albumId=${detail.party.albumId}'),
            child: const Icon(Icons.camera_alt_rounded),
          );
        },
      ),
    );
  }
}
