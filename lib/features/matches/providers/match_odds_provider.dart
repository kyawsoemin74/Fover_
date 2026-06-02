import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchOddsStatus { initial, loading, loaded, error }

class MatchOddsState {
  const MatchOddsState({
    this.status = MatchOddsStatus.initial,
    this.odds,
    this.errorMessage,
  });

  final MatchOddsStatus status;
  final MatchOddsInfo? odds;
  final String? errorMessage;

  MatchOddsState copyWith({
    MatchOddsStatus? status,
    MatchOddsInfo? odds,
    String? errorMessage,
  }) {
    return MatchOddsState(
      status: status ?? this.status,
      odds: odds ?? this.odds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MatchOddsNotifier extends StateNotifier<MatchOddsState> {
  MatchOddsNotifier(this._repository, this._matchId) : super(const MatchOddsState());

  final MatchDetailRepository _repository;
  final int _matchId;

  Future<void> loadOdds() async {
    if (state.status == MatchOddsStatus.loading) return;

    state = state.copyWith(status: MatchOddsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchOdds(_matchId);
    if (result.isSuccess) {
      state = state.copyWith(status: MatchOddsStatus.loaded, odds: result.data);
    } else {
      state = state.copyWith(status: MatchOddsStatus.error, errorMessage: result.error);
    }
  }
}

final matchOddsProvider = StateNotifierProvider.family<MatchOddsNotifier, MatchOddsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);
    return MatchOddsNotifier(repository, matchId);
  },
);
