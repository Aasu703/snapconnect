import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';

/// Screen showing active parties with tabs for all and joined parties.
class PartiesScreen extends ConsumerWidget {
  const PartiesScreen({super.key});

  /// Enforces identity before creating a new party.
  Future<void> _createParty(BuildContext context, WidgetRef ref) async {
    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Party creation requires a host identity.',
      );
    }

    if (ref.read(sessionProvider) == null || !context.mounted) {
      return;
    }

    context.push('/party/create');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPartiesAsync = ref.watch(partiesProvider);
    final myPartiesAsync = ref.watch(myPartiesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parties'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Parties'),
              Tab(text: 'My Parties'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PartyListView(
              asyncValue: allPartiesAsync,
              emptyTitle: 'No active parties',
              emptySubtitle: 'Create one to invite everyone and upload live.',
              onRetry: () => ref.invalidate(partiesProvider),
            ),
            _PartyListView(
              asyncValue: myPartiesAsync,
              emptyTitle: 'You have not joined any parties',
              emptySubtitle: 'Join a party via code or QR to see it here.',
              onRetry: () => ref.invalidate(myPartiesProvider),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createParty(context, ref),
          icon: const Icon(Icons.celebration_outlined),
          label: const Text('Create Party'),
        ),
      ),
    );
  }
}

class _PartyListView extends StatelessWidget {
  const _PartyListView({
    required this.asyncValue,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRetry,
  });

  final AsyncValue<dynamic> asyncValue;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: asyncValue.when(
        loading: () => const LoadingSkeleton(columns: 1, itemCount: 6),
        error: (error, _) => EmptyState(
          title: 'Could not load parties',
          subtitle: error.toString(),
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
        data: (parties) {
          if (parties.isEmpty) {
            return EmptyState(
              title: emptyTitle,
              subtitle: emptySubtitle,
              icon: Icons.celebration_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: parties.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final party = parties[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/party/${party.joinCode}'),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              party.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              party.joinCode,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Host: ${party.hostName}'),
                      const SizedBox(height: 4),
                      Text('Members: ${party.memberCount}'),
                      if (party.description != null && party.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          party.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
