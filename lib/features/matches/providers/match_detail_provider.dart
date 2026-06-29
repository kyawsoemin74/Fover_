import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/matches/data/match_detail_repository_impl.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';
import 'package:fover/features/matches/providers/match_detail_state.dart';

final matchDetailRepositoryProvider = Provider<MatchDetailRepository>((ref) {
  return MatchDetailRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final matchDetailProvider = StateNotifierProvider.family<MatchDetailNotifier, MatchDetailState, int>((ref, matchId) {
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
  final Map<MatchDetailTab, Future<void> Function({bool forceRefresh})> _tabLoaders = {};
  final Set<MatchDetailTab> _loadedTabs = <MatchDetailTab>{};
  final Set<MatchDetailTab> _loadingTabs = <MatchDetailTab>{};

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

  void registerTabLoader(
    MatchDetailTab tab,
    Future<void> Function({bool forceRefresh}) loader,
  ) {
    _tabLoaders[tab] = loader;
  }

  Future<void> setSelectedTab(
    MatchDetailTab tab, {
    bool forceRefresh = false,
  }) async {
    if (state.selectedTab == tab && !forceRefresh) return;

    state = state.copyWith(selectedTab: tab);
    await _maybeLoadTabData(tab, forceRefresh: forceRefresh);
  }

  Future<void> _maybeLoadTabData(
    MatchDetailTab tab, {
    bool forceRefresh = false,
  }) async {
    if (tab == MatchDetailTab.details ||
        tab == MatchDetailTab.standings ||
        tab == MatchDetailTab.knockout) {
      return;
    }

    if (_loadingTabs.contains(tab)) return;
    if (!forceRefresh && (_loadedTabs.contains(tab) || _tabLoaders[tab] == null)) {
      return;
    }

    _loadingTabs.add(tab);
    try {
      await _tabLoaders[tab]!(forceRefresh: forceRefresh);
      _loadedTabs.add(tab);
    } finally {
      _loadingTabs.remove(tab);
    }
  }
}
