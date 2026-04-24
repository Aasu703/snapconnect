import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Screen showing active parties with explicit async states.
class PartiesScreen extends ConsumerStatefulWidget {
  const PartiesScreen({super.key});

  @override
  ConsumerState<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends ConsumerState<PartiesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('PartiesScreen mounted');
  }

  Future<void> _createParty() async {
    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Party creation requires a host identity.',
      );
    }

    if (!mounted || ref.read(sessionProvider) == null) {
      return;
    }

    context.push('/party/create');
  }

  Future<void> _refreshAllParties() async {
    ref.invalidate(partiesProvider);
    try {
      await ref.read(partiesProvider.future);
    } catch (e) {
      debugPrint('PartiesScreen refresh all error: $e');
    }
  }

  Future<void> _refreshMyParties() async {
    ref.invalidate(myPartiesProvider);
    try {
      await ref.read(myPartiesProvider.future);
    } catch (e) {
      debugPrint('PartiesScreen refresh mine error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('PartiesScreen build called');
    final allPartiesAsync = ref.watch(partiesProvider);
    final myPartiesAsync = ref.watch(myPartiesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Parties',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
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
              listName: 'All parties',
              emptyTitle: 'No parties yet',
              emptySubtitle: 'No parties yet. Create one! 🎉',
              onRefresh: _refreshAllParties,
            ),
            _PartyListView(
              asyncValue: myPartiesAsync,
              listName: 'My parties',
              emptyTitle: 'You have not joined any parties',
              emptySubtitle: 'Join a party via code or QR to see it here.',
              onRefresh: _refreshMyParties,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createParty,
          backgroundColor: const Color(0xFF4D96FF),
          foregroundColor: Colors.white,
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
    required this.listName,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
  });

  final AsyncValue<List<PartyModel>> asyncValue;
  final String listName;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () {
        debugPrint('$listName: loading state');
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        debugPrint('$listName error: $error');
        debugPrint('$listName stack: $stack');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load parties',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      },
      data: (parties) {
        debugPrint('$listName loaded: ${parties.length} parties');
        if (parties.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    emptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE3E5E8)),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              party.joinCode,
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Host: ${party.hostName}'),
                      const SizedBox(height: 4),
                      Text('Members: ${party.memberCount}'),
                      if (party.description != null &&
                          party.description!.isNotEmpty) ...[
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
          ),
        );
      },
    );
  }
}
