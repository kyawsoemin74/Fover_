import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';

enum MatchEventsStatus { initial, loading, loaded, error }

class MatchEventsState {
  const MatchEventsState({
    this.status = MatchEventsStatus.initial,
    this.events = const [],
    this.errorMessage,
  });

  final MatchEventsStatus status;
  final List<MatchEventInfo> events;
  final String? errorMessage;

  MatchEventsState copyWith({
    MatchEventsStatus? status,
    List<MatchEventInfo>? events,
    String? errorMessage,
  }) {
    return MatchEventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MatchEventsNotifier extends StateNotifier<MatchEventsState> {
  MatchEventsNotifier(this._repository, this._matchId) : super(const MatchEventsState());

  final MatchDetailRepository _repository;
  final int _matchId;

  Future<void> loadEvents() async {
    if (state.status == MatchEventsStatus.loading) return;

    state = state.copyWith(status: MatchEventsStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchEvents(_matchId);
    if (result.isSuccess) {
      final events = result.data ?? const [];
      debugPrint('[MatchEventsNotifier] loaded ${events.length} events: ${events.map((e) => '${e.minute}+${e.extraMinute} rawMinute=${e.raw['time_elapsed'] ?? e.raw['elapsed'] ?? e.raw['minute'] ?? e.raw['time']} rawExtra=${e.raw['time_extra'] ?? e.raw['extra'] ?? e.raw['extra_minute']}').join('; ')}');
      state = state.copyWith(status: MatchEventsStatus.loaded, events: events);
    } else {
      state = state.copyWith(status: MatchEventsStatus.error, errorMessage: result.error);
    }
  }
}

final matchEventsProvider = StateNotifierProvider.family<MatchEventsNotifier, MatchEventsState, int>(
  (ref, matchId) {
    final repository = ref.watch(matchDetailRepositoryProvider);
    return MatchEventsNotifier(repository, matchId);
  },
);
