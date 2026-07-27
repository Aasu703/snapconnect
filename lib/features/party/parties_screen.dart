import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/blocs/party_bloc.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/common/common.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

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

  void _joinParty() {
    context.push(RoutePaths.joinPartyEntry);
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
        backgroundColor: context.appColors.screenBackground,
        appBar: AppBar(
          title: Text(
            AppStrings.parties,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: context.colors.surface,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Join with code or QR',
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: _joinParty,
            ),
          ],
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
              emptyActionLabel: AppStrings.createParty,
              onRefresh: _refreshAllParties,
              onEmptyAction: _createParty,
            ),
            _PartyListView(
              isLoading: partyState.isLoadingMyParties && partyState.myParties == null,
              error: partyState.myPartiesError != null && partyState.myParties == null ? partyState.myPartiesError : null,
              parties: partyState.myParties,
              listName: 'My parties',
              emptyTitle: 'You have not joined any parties',
              emptySubtitle: 'Join a party via code or QR to see it here.',
              emptyActionLabel: AppStrings.joinParty,
              onRefresh: _refreshMyParties,
              onEmptyAction: () async => _joinParty(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createParty,
          backgroundColor: context.appColors.accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.celebration_outlined),
          label: const Text(AppStrings.createParty),
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
    required this.emptyActionLabel,
    required this.onRefresh,
    required this.onEmptyAction,
  });

  final bool isLoading;
  final String? error;
  final List<PartyModel>? parties;
  final String listName;
  final String emptyTitle;
  final String emptySubtitle;
  final String emptyActionLabel;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onEmptyAction;

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
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppDimens.iconXl,
                color: context.appColors.danger,
              ),
              const Gap(AppDimens.md),
              Text(
                'Failed to load parties',
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(AppDimens.sm),
              Text(
                error.toString(),
                style: context.text.bodySmall
                    ?.copyWith(color: context.appColors.mutedText),
                textAlign: TextAlign.center,
              ),
              const Gap(AppDimens.md),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text(AppStrings.tryAgain),
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
        actionLabel: emptyActionLabel,
        onAction: () => onEmptyAction(),
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
              padding: const EdgeInsets.all(AppDimens.space14),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: context.appColors.cardBorder),
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
                          horizontal: AppDimens.space10,
                          vertical: AppDimens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text(
                          party.joinCode,
                          style: TextStyle(
                            color: context.appColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppDimens.sm),
                  Text('Host: ${party.hostName}'),
                  const Gap(AppDimens.space4),
                  Text('Members: ${party.memberCount}'),
                  if (party.description != null &&
                      party.description!.isNotEmpty) ...[
                    const Gap(AppDimens.sm),
                    Text(
                      party.description!,
                      style: context.text.bodyMedium,
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
