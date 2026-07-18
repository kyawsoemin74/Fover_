import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/builders/goal_summary_builder.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/goal_summary_result.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchEventsStatus { initial, loading, loaded, empty, error }

class MatchEventsState {
  const MatchEventsState({
    this.status = MatchEventsStatus.initial,
    this.events = const [],
    this.goalSummary,
    this.errorMessage,
    this.lastLoadedAt,
  });

  final MatchEventsStatus status;
  final List<MatchEventInfo> events;
  final GoalSummaryResult? goalSummary;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  MatchEventsState copyWith({
    MatchEventsStatus? status,
    List<MatchEventInfo>? events,
    GoalSummaryResult? goalSummary,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return MatchEventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      goalSummary: goalSummary ?? this.goalSummary,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}

class MatchEventsNotifier extends StateNotifier<MatchEventsState> {
  MatchEventsNotifier(
    this._repository,
    this._matchId,
    this._readMatchStatus,
  ) : super(const MatchEventsState());

  final MatchDetailRepository _repository;
  final int _matchId;
  final String? Function() _readMatchStatus;
  final GoalSummaryBuilder _goalSummaryBuilder = const GoalSummaryBuilder();

  Future<void> loadEvents({bool forceRefresh = false}) async {
    if (state.status == MatchEventsStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(status: MatchEventsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchEvents(_matchId);
    if (result.isSuccess) {
      final events = result.data ?? const [];
      final matchDetail = await _repository.fetchMatchDetail(_matchId);
      final homeTeamId = matchDetail.isSuccess ? matchDetail.data?.homeTeamId ?? 0 : 0;
      final awayTeamId = matchDetail.isSuccess ? matchDetail.data?.awayTeamId ?? 0 : 0;
      final goalSummary = _goalSummaryBuilder.build(
        events,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      );
      state = state.copyWith(
        status: events.isEmpty ? MatchEventsStatus.empty : MatchEventsStatus.loaded,
        events: events,
        goalSummary: goalSummary,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(status: MatchEventsStatus.error, errorMessage: result.error);
    }
  }

  bool _shouldUseCache() {
    if (state.status != MatchEventsStatus.loaded && state.status != MatchEventsStatus.empty) {
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

final matchEventsProvider = StateNotifierProvider.family<MatchEventsNotifier, MatchEventsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);

    String? readMatchStatus() {
      return ref.read(matchDetailProvider(matchId)).matchDetail?.status;
    }

    return MatchEventsNotifier(repository, matchId, readMatchStatus);
  },
);
