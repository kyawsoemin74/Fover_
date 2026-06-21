import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchStatsStatus { initial, loading, loaded, empty, error }

class MatchStatsState {
  const MatchStatsState({
    this.status = MatchStatsStatus.initial,
    this.stats,
    this.errorMessage,
    this.lastLoadedAt,
  });

  final MatchStatsStatus status;
  final MatchStatsInfo? stats;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  MatchStatsState copyWith({
    MatchStatsStatus? status,
    MatchStatsInfo? stats,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return MatchStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}

class MatchStatsNotifier extends StateNotifier<MatchStatsState> {
  MatchStatsNotifier(
    this._repository,
    this._matchId,
    this._readMatchStatus,
  ) : super(const MatchStatsState());

  final MatchDetailRepository _repository;
  final int _matchId;
  final String? Function() _readMatchStatus;

  Future<void> loadStats({bool forceRefresh = false}) async {
    if (state.status == MatchStatsStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(status: MatchStatsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchStats(_matchId);
    if (result.isSuccess) {
      final stats = result.data;
      state = state.copyWith(
        status: stats != null && stats.hasData ? MatchStatsStatus.loaded : MatchStatsStatus.empty,
        stats: stats,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(status: MatchStatsStatus.error, errorMessage: result.error);
    }
  }

  bool _shouldUseCache() {
    if (state.status != MatchStatsStatus.loaded && state.status != MatchStatsStatus.empty) {
      return false;
    }

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

final matchStatsProvider = StateNotifierProvider.family<MatchStatsNotifier, MatchStatsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);

    String? readMatchStatus() {
      return ref.read(matchDetailProvider(matchId)).matchDetail?.status;
    }

    return MatchStatsNotifier(repository, matchId, readMatchStatus);
  },
);
