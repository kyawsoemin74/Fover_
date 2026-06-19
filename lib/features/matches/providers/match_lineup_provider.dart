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
    this.lastLoadedAt,
  });

  final MatchLineupStatus status;
  final MatchLineupInfo? lineup;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  MatchLineupState copyWith({
    MatchLineupStatus? status,
    MatchLineupInfo? lineup,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return MatchLineupState(
      status: status ?? this.status,
      lineup: lineup ?? this.lineup,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}

class MatchLineupNotifier extends StateNotifier<MatchLineupState> {
  MatchLineupNotifier(
    this._repository,
    this._matchId,
    this._readMatchStatus,
  ) : super(const MatchLineupState());

  final MatchDetailRepository _repository;
  final int _matchId;
  final String? Function() _readMatchStatus;

  Future<void> loadLineup({bool forceRefresh = false}) async {
    if (state.status == MatchLineupStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(status: MatchLineupStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchLineup(_matchId);
    if (result.isSuccess) {
      state = state.copyWith(
        status: MatchLineupStatus.loaded,
        lineup: result.data,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(status: MatchLineupStatus.error, errorMessage: result.error);
    }
  }

  bool _shouldUseCache() {
    if (state.status != MatchLineupStatus.loaded || state.lineup == null) {
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

final matchLineupProvider = StateNotifierProvider.family<MatchLineupNotifier, MatchLineupState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);

    String? readMatchStatus() {
      return ref.read(matchDetailProvider(matchId)).matchDetail?.status;
    }

    return MatchLineupNotifier(repository, matchId, readMatchStatus);
  },
);
