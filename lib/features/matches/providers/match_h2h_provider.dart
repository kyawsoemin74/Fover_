import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

class MatchH2HRequest {
  const MatchH2HRequest({
    required this.matchId,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int matchId;
  final int homeTeamId;
  final int awayTeamId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchH2HRequest &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          homeTeamId == other.homeTeamId &&
          awayTeamId == other.awayTeamId;

  @override
  int get hashCode => Object.hash(matchId, homeTeamId, awayTeamId);
}

enum MatchH2HStatus { initial, loading, loaded, error }

class MatchH2HState {
  const MatchH2HState({
    this.status = MatchH2HStatus.initial,
    this.h2h,
    this.errorMessage,
    this.lastLoadedAt,
  });

  final MatchH2HStatus status;
  final MatchH2HInfo? h2h;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  MatchH2HState copyWith({
    MatchH2HStatus? status,
    MatchH2HInfo? h2h,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return MatchH2HState(
      status: status ?? this.status,
      h2h: h2h ?? this.h2h,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}

class MatchH2HNotifier extends StateNotifier<MatchH2HState> {
  MatchH2HNotifier(this._repository, this._request, this._readMatchStatus)
    : super(const MatchH2HState());

  final MatchDetailRepository _repository;
  final MatchH2HRequest _request;
  final String? Function() _readMatchStatus;

  Future<void> loadH2H({bool forceRefresh = false}) async {
    if (state.status == MatchH2HStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(status: MatchH2HStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchH2H(
      _request.matchId,
      _request.homeTeamId,
      _request.awayTeamId,
    );
    if (result.isSuccess) {
      state = state.copyWith(
        status: MatchH2HStatus.loaded,
        h2h: result.data,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(
        status: MatchH2HStatus.error,
        errorMessage: result.error,
      );
    }
  }

  bool _shouldUseCache() {
    if (state.status != MatchH2HStatus.loaded || state.h2h == null) {
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

final matchH2HProvider =
    StateNotifierProvider.family<
      MatchH2HNotifier,
      MatchH2HState,
      MatchH2HRequest
    >((ref, request) {
      final repository = ref.watch(matchDetailRepositoryProvider);

      String? readMatchStatus() {
        return ref
            .read(matchDetailProvider(request.matchId))
            .matchDetail
            ?.status;
      }

      return MatchH2HNotifier(repository, request, readMatchStatus);
    });
