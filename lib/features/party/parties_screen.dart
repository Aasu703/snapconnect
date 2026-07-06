import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/blocs/party_bloc.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';

/// Screen showing active parties with explicit async states.
class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('PartiesScreen mounted');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartyBloc>().add(FetchParties());
      context.read<PartyBloc>().add(FetchMyParties(context.read<SessionCubit>().state));
    });
  }

  Future<void> _createParty() async {
    if (context.read<SessionCubit>().state == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Party creation requires a host identity.',
      );
    }

    if (!mounted || context.read<SessionCubit>().state == null) {
      return;
    }

    context.push('/party/create');
  }

  Future<void> _refreshAllParties() async {
    context.read<PartyBloc>().add(FetchParties());
  }

  Future<void> _refreshMyParties() async {
    context.read<PartyBloc>().add(FetchMyParties(context.read<SessionCubit>().state));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('PartiesScreen build called');
    final partyState = context.watch<PartyBloc>().state;

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
              isLoading: partyState.isLoadingParties && partyState.parties == null,
              error: partyState.partiesError != null && partyState.parties == null ? partyState.partiesError : null,
              parties: partyState.parties,
              listName: 'All parties',
              emptyTitle: 'No parties yet',
              emptySubtitle: 'No parties yet. Create one! 🎉',
              onRefresh: _refreshAllParties,
              onCreateParty: _createParty,
            ),
            _PartyListView(
              isLoading: partyState.isLoadingMyParties && partyState.myParties == null,
              error: partyState.myPartiesError != null && partyState.myParties == null ? partyState.myPartiesError : null,
              parties: partyState.myParties,
              listName: 'My parties',
              emptyTitle: 'You have not joined any parties',
              emptySubtitle: 'Join a party via code or QR to see it here.',
              onRefresh: _refreshMyParties,
              onCreateParty: _createParty,
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
    required this.isLoading,
    required this.error,
    required this.parties,
    required this.listName,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onCreateParty,
  });

  final bool isLoading;
  final String? error;
  final List<PartyModel>? parties;
  final String listName;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onCreateParty;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      debugPrint('$listName: loading state');
      return const LoadingSkeleton(columns: 2, itemCount: 6);
    }

    if (error != null) {
      debugPrint('$listName error: $error');
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
    }

    final pList = parties ?? [];
    debugPrint('$listName loaded: ${pList.length} parties');
    if (pList.isEmpty) {
      return EmptyState(
        emoji: '🎉',
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: 'Create Party',
        onAction: () => onCreateParty(),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: pList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final party = pList[index];

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
                          party.fullName,
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
  }
}
