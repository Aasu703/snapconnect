import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snapconnect/common/theme/context_extensions.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/features/events/data/repositories/event_repository_impl.dart';
import 'package:snapconnect/features/events/domain/entities/event_entity.dart';

/// Host dashboard displaying all events created by the current user
/// with attendee metrics, photo counts, and quick actions.
class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() =>
      _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  final _repo = EventRepositoryImpl();
  List<EventEntity> _events = [];
  Map<String, Map<String, int>> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final user = context.read<SessionCubit>().state;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final events = await _repo.fetchHostEvents(user.id);
      final stats = <String, Map<String, int>>{};
      for (final event in events) {
        try {
          stats[event.id] = await _repo.fetchEventStats(event.id);
        } catch (_) {
          stats[event.id] = {'photos': 0, 'guests': 0};
        }
      }
      if (mounted) {
        setState(() {
          _events = events;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Events',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: context.colors.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                        ),
                        const Gap(4),
                        Text(
                          '${_events.length} event${_events.length != 1 ? 's' : ''} hosted',
                          style: TextStyle(
                            color: context.appColors.mutedText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CreateEventFab(onTap: () => context.push('/events/create')),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const Gap(20),
            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _events.isEmpty
                  ? _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _events.length,
                        separatorBuilder: (_, _) => const Gap(14),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final stat =
                              _stats[event.id] ?? {'photos': 0, 'guests': 0};
                          return _EventCard(
                                event: event,
                                photoCount: stat['photos'] ?? 0,
                                guestCount: stat['guests'] ?? 0,
                                onViewQR: () => context.push(
                                  '/events/${event.joinCode}/qr',
                                ),
                                onManageAlbum: () => context.push(
                                  '/events/${event.joinCode}/album',
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 80 * index),
                                duration: 400.ms,
                              )
                              .slideX(begin: 0.05, end: 0, duration: 400.ms);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEventFab extends StatelessWidget {
  const _CreateEventFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accentPurple],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.photoCount,
    required this.guestCount,
    required this.onViewQR,
    required this.onManageAlbum,
  });

  final EventEntity event;
  final int photoCount;
  final int guestCount;
  final VoidCallback onViewQR;
  final VoidCallback onManageAlbum;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(
                    color: context.colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: event.isActive
                      ? AppColors.success.withValues(alpha: 0.15)
                      : context.appColors.mutedText.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.isActive
                            ? AppColors.success
                            : context.appColors.mutedText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.isActive ? 'Live' : 'Ended',
                      style: TextStyle(
                        color: event.isActive
                            ? AppColors.success
                            : context.appColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (event.description != null) ...[
            const Gap(6),
            Text(
              event.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.mutedText,
                fontSize: 13,
              ),
            ),
          ],
          const Gap(14),
          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.photo_library_rounded,
                label: '$photoCount photos',
              ),
              const Gap(12),
              _StatChip(icon: Icons.group_rounded, label: '$guestCount guests'),
              if (event.eventDate != null) ...[
                const Gap(12),
                _StatChip(
                  icon: Icons.calendar_today_rounded,
                  label: DateFormat.MMMd().format(event.eventDate!),
                ),
              ],
            ],
          ),
          const Gap(14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.qr_code_rounded,
                  label: 'QR Code',
                  onTap: onViewQR,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Album',
                  onTap: onManageAlbum,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.appColors.mutedText),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: context.appColors.mutedText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.appColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.celebration_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const Gap(20),
          Text(
            'No events yet',
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Create your first event to get started',
            style: TextStyle(
              color: context.appColors.mutedText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
