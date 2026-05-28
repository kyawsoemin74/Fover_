import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_lineup_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchLineupStatus { initial, loading, loaded, error }

class MatchLineupState {
  const MatchLineupState({
    this.status = MatchLineupStatus.initial,
    this.lineup,
    this.errorMessage,
  });

  final MatchLineupStatus status;
  final MatchLineupInfo? lineup;
  final String? errorMessage;

  MatchLineupState copyWith({
    MatchLineupStatus? status,
    MatchLineupInfo? lineup,
    String? errorMessage,
  }) {
    return MatchLineupState(
      status: status ?? this.status,
      lineup: lineup ?? this.lineup,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MatchLineupNotifier extends StateNotifier<MatchLineupState> {
  MatchLineupNotifier(this._repository, this._matchId) : super(const MatchLineupState());

  final MatchDetailRepository _repository;
  final int _matchId;

  Future<void> loadLineup() async {
    if (state.status == MatchLineupStatus.loading) return;

    state = state.copyWith(status: MatchLineupStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchLineup(_matchId);
    if (result.isSuccess) {
      state = state.copyWith(status: MatchLineupStatus.loaded, lineup: result.data);
    } else {
      state = state.copyWith(status: MatchLineupStatus.error, errorMessage: result.error);
    }
  }
}

final matchLineupProvider = StateNotifierProvider.autoDispose.family<MatchLineupNotifier, MatchLineupState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);
    return MatchLineupNotifier(repository, matchId);
  },
);
