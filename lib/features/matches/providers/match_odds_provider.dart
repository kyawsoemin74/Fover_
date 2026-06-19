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
    this.lastLoadedAt,
  });

  final MatchOddsStatus status;
  final MatchOddsInfo? odds;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  MatchOddsState copyWith({
    MatchOddsStatus? status,
    MatchOddsInfo? odds,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return MatchOddsState(
      status: status ?? this.status,
      odds: odds ?? this.odds,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}

class MatchOddsNotifier extends StateNotifier<MatchOddsState> {
  MatchOddsNotifier(
    this._repository,
    this._matchId,
    this._readMatchStatus,
  ) : super(const MatchOddsState());

  final MatchDetailRepository _repository;
  final int _matchId;
  final String? Function() _readMatchStatus;

  Future<void> loadOdds({bool forceRefresh = false}) async {
    if (state.status == MatchOddsStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(status: MatchOddsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchOdds(_matchId);
    if (result.isSuccess) {
      state = state.copyWith(
        status: MatchOddsStatus.loaded,
        odds: result.data,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(status: MatchOddsStatus.error, errorMessage: result.error);
    }
  }

  bool _shouldUseCache() {
    if (state.status != MatchOddsStatus.loaded) return false;
    final loadedAt = state.lastLoadedAt;
    if (loadedAt == null) return false;

    final ttl = _resolveTtl();
    if (ttl == null) {
      return true;
    }

    return DateTime.now().difference(loadedAt) < ttl;
  }

  Duration? _resolveTtl() {
    final status = _readMatchStatus()?.trim().toUpperCase();

    const liveStatuses = {'LIVE', '1H', 'HT', '2H', 'ET'};
    const preMatchStatuses = {'NS', 'TBD', 'PST'};
    const finalStatuses = {'FT', 'AET', 'PEN'};

    if (status != null && finalStatuses.contains(status)) {
      return null;
    }

    if (status != null && liveStatuses.contains(status)) {
      return const Duration(seconds: 60);
    }

    if (status != null && preMatchStatuses.contains(status)) {
      return const Duration(minutes: 5);
    }

    return const Duration(minutes: 5);
  }
}

final matchOddsProvider = StateNotifierProvider.family<MatchOddsNotifier, MatchOddsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);

    String? readMatchStatus() {
      return ref.read(matchDetailProvider(matchId)).matchDetail?.status;
    }

    return MatchOddsNotifier(repository, matchId, readMatchStatus);
  },
);
