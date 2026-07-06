import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/features/party/party_controller.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:equatable/equatable.dart';

// ── Events ─────────────────────────────────────────────────────────────────
abstract class PartyEvent extends Equatable {
  const PartyEvent();
  @override
  List<Object?> get props => [];
}

class FetchParties extends PartyEvent {}

class FetchMyParties extends PartyEvent {
  final UserModel? user;
  const FetchMyParties(this.user);
  @override
  List<Object?> get props => [user];
}

class FetchPartyDetail extends PartyEvent {
  final String joinCode;
  const FetchPartyDetail(this.joinCode);
  @override
  List<Object?> get props => [joinCode];
}

// ── State ──────────────────────────────────────────────────────────────────
class PartyState extends Equatable {
  final List<PartyModel>? parties;
  final bool isLoadingParties;
  final String? partiesError;

  final List<PartyModel>? myParties;
  final bool isLoadingMyParties;
  final String? myPartiesError;

  final PartyDetailData? partyDetail;
  final bool isLoadingPartyDetail;
  final String? partyDetailError;

  const PartyState({
    this.parties,
    this.isLoadingParties = false,
    this.partiesError,
    this.myParties,
    this.isLoadingMyParties = false,
    this.myPartiesError,
    this.partyDetail,
    this.isLoadingPartyDetail = false,
    this.partyDetailError,
  });

  PartyState copyWith({
    List<PartyModel>? parties,
    bool? isLoadingParties,
    String? partiesError,
    List<PartyModel>? myParties,
    bool? isLoadingMyParties,
    String? myPartiesError,
    PartyDetailData? partyDetail,
    bool? isLoadingPartyDetail,
    String? partyDetailError,
  }) {
    return PartyState(
      parties: parties ?? this.parties,
      isLoadingParties: isLoadingParties ?? this.isLoadingParties,
      partiesError: partiesError ?? this.partiesError,
      myParties: myParties ?? this.myParties,
      isLoadingMyParties: isLoadingMyParties ?? this.isLoadingMyParties,
      myPartiesError: myPartiesError ?? this.myPartiesError,
      partyDetail: partyDetail ?? this.partyDetail,
      isLoadingPartyDetail: isLoadingPartyDetail ?? this.isLoadingPartyDetail,
      partyDetailError: partyDetailError ?? this.partyDetailError,
    );
  }

  @override
  List<Object?> get props => [
        parties,
        isLoadingParties,
        partiesError,
        myParties,
        isLoadingMyParties,
        myPartiesError,
        partyDetail,
        isLoadingPartyDetail,
        partyDetailError,
      ];
}

// ── Bloc ───────────────────────────────────────────────────────────────────
class PartyBloc extends Bloc<PartyEvent, PartyState> {
  final PartyController _partyController;

  PartyBloc(this._partyController) : super(const PartyState()) {
    on<FetchParties>(_onFetchParties);
    on<FetchMyParties>(_onFetchMyParties);
    on<FetchPartyDetail>(_onFetchPartyDetail);
    sl<AppLogger>().debug('PartyBloc initialized');
  }

  Future<void> _onFetchParties(FetchParties event, Emitter<PartyState> emit) async {
    emit(state.copyWith(isLoadingParties: true, partiesError: null));
    sl<AppLogger>().info('Fetching all parties');
    try {
      final parties = await _partyController.fetchAllParties();
      emit(state.copyWith(parties: parties, isLoadingParties: false));
      sl<AppLogger>().good('Fetched ${parties.length} parties');
    } catch (e) {
      sl<AppLogger>().error('Error fetching all parties: $e');
      emit(state.copyWith(isLoadingParties: false, partiesError: e.toString()));
    }
  }

  Future<void> _onFetchMyParties(FetchMyParties event, Emitter<PartyState> emit) async {
    if (event.user == null) {
      sl<AppLogger>().warning('Cannot fetch my parties, user is null');
      emit(state.copyWith(myParties: const []));
      return;
    }
    emit(state.copyWith(isLoadingMyParties: true, myPartiesError: null));
    sl<AppLogger>().info('Fetching parties for user: ${event.user!.id}');
    try {
      final myParties = await _partyController.fetchMyParties(event.user!.id);
      emit(state.copyWith(myParties: myParties, isLoadingMyParties: false));
      sl<AppLogger>().good('Fetched ${myParties.length} user parties');
    } catch (e) {
      sl<AppLogger>().error('Error fetching my parties: $e');
      emit(state.copyWith(isLoadingMyParties: false, myPartiesError: e.toString()));
    }
  }

  Future<void> _onFetchPartyDetail(FetchPartyDetail event, Emitter<PartyState> emit) async {
    emit(state.copyWith(isLoadingPartyDetail: true, partyDetailError: null));
    sl<AppLogger>().info('Fetching party details for code: ${event.joinCode}');
    try {
      final detail = await _partyController.fetchPartyDetail(event.joinCode);
      emit(state.copyWith(partyDetail: detail, isLoadingPartyDetail: false));
      sl<AppLogger>().good('Fetched party details');
    } catch (e) {
      sl<AppLogger>().error('Error fetching party details: $e');
      emit(state.copyWith(isLoadingPartyDetail: false, partyDetailError: e.toString()));
    }
  }
}
