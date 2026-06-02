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
}

enum MatchH2HStatus { initial, loading, loaded, error }

class MatchH2HState {
  const MatchH2HState({
    this.status = MatchH2HStatus.initial,
    this.h2h,
    this.errorMessage,
  });

  final MatchH2HStatus status;
  final MatchH2HInfo? h2h;
  final String? errorMessage;

  MatchH2HState copyWith({
    MatchH2HStatus? status,
    MatchH2HInfo? h2h,
    String? errorMessage,
  }) {
    return MatchH2HState(
      status: status ?? this.status,
      h2h: h2h ?? this.h2h,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MatchH2HNotifier extends StateNotifier<MatchH2HState> {
  MatchH2HNotifier(this._repository, this._request) : super(const MatchH2HState());

  final MatchDetailRepository _repository;
  final MatchH2HRequest _request;

  Future<void> loadH2H() async {
    if (state.status == MatchH2HStatus.loading) return;

    state = state.copyWith(status: MatchH2HStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchH2H(_request.matchId, _request.homeTeamId, _request.awayTeamId);
    if (result.isSuccess) {
      state = state.copyWith(status: MatchH2HStatus.loaded, h2h: result.data);
    } else {
      state = state.copyWith(status: MatchH2HStatus.error, errorMessage: result.error);
    }
  }
}

final matchH2HProvider = StateNotifierProvider.family<MatchH2HNotifier, MatchH2HState, MatchH2HRequest>(
  (ref, request) {
    final repository = ref.watch(matchDetailRepositoryProvider);
    return MatchH2HNotifier(repository, request);
  },
);
