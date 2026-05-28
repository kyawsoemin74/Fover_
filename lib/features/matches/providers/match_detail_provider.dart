import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/matches/data/match_detail_repository_impl.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/providers/match_detail_state.dart';

final matchDetailRepositoryProvider = Provider<MatchDetailRepository>((ref) {
  return MatchDetailRepositoryImpl(dioClient: DioClient());
});

final matchDetailProvider = StateNotifierProvider.autoDispose.family<MatchDetailNotifier, MatchDetailState, int>((ref, matchId) {
  final repository = ref.watch(matchDetailRepositoryProvider);
  final notifier = MatchDetailNotifier(repository);

  if (matchId > 0) {
    Future.microtask(() => notifier.loadMatch(matchId));
  }

  return notifier;
});

class MatchDetailNotifier extends StateNotifier<MatchDetailState> {
  MatchDetailNotifier(this._repository) : super(const MatchDetailState());

  final MatchDetailRepository _repository;

  Future<void> loadMatch(int matchId) async {
    state = state.copyWith(status: MatchDetailStatus.loading, errorMessage: null);
    final result = await _repository.fetchMatchDetail(matchId);
    if (result.isSuccess) {
      state = state.copyWith(status: MatchDetailStatus.loaded, matchDetail: result.data, errorMessage: null);
    } else {
      state = state.copyWith(status: MatchDetailStatus.error, errorMessage: result.error);
    }
  }

  Future<void> refreshMatch(int matchId) async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchMatchDetail(matchId);
    if (result.isSuccess) {
      state = state.copyWith(
        status: MatchDetailStatus.loaded,
        matchDetail: result.data,
        errorMessage: null,
        isRefreshing: false,
      );
    } else {
      state = state.copyWith(
        status: MatchDetailStatus.error,
        errorMessage: result.error,
        isRefreshing: false,
      );
    }
  }
}
