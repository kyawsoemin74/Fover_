import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchStatsStatus { initial, loading, loaded, error }

class MatchStatsState {
  const MatchStatsState({
    this.status = MatchStatsStatus.initial,
    this.stats,
    this.errorMessage,
  });

  final MatchStatsStatus status;
  final MatchStatsInfo? stats;
  final String? errorMessage;

  MatchStatsState copyWith({
    MatchStatsStatus? status,
    MatchStatsInfo? stats,
    String? errorMessage,
  }) {
    return MatchStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MatchStatsNotifier extends StateNotifier<MatchStatsState> {
  MatchStatsNotifier(this._repository, this._matchId) : super(const MatchStatsState());

  final MatchDetailRepository _repository;
  final int _matchId;

  Future<void> loadStats() async {
    if (state.status == MatchStatsStatus.loading) return;

    state = state.copyWith(status: MatchStatsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchStats(_matchId);
    if (result.isSuccess) {
      state = state.copyWith(status: MatchStatsStatus.loaded, stats: result.data);
    } else {
      state = state.copyWith(status: MatchStatsStatus.error, errorMessage: result.error);
    }
  }
}

final matchStatsProvider = StateNotifierProvider.autoDispose.family<MatchStatsNotifier, MatchStatsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);
    return MatchStatsNotifier(repository, matchId);
  },
);
