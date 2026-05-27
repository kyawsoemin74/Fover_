import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/providers/navigation_provider.dart';
import 'package:fover/features/home/data/home_repository_impl.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/providers/home_state.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl();
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._repository) : super(const HomeState()) {
    loadMatches();
  }

  final HomeRepository _repository;

  Future<void> loadMatches() async {
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(state.selectedTab.dateFor(DateTime.now()));
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchLeagueMatches(
      state.selectedTab.dateFor(DateTime.now()),
      forceRefresh: true,
    );
    _handleResult(result, refreshing: true);
  }

  void toggleFollowing() {
    state = state.copyWith(showFollowing: !state.showFollowing);
  }

  void toggleLeagueExpanded(String leagueId) {
    final next = Set<String>.from(state.expandedLeagueIds);
    if (next.contains(leagueId)) {
      next.remove(leagueId);
    } else {
      next.add(leagueId);
    }
    state = state.copyWith(expandedLeagueIds: next);
  }

  Future<void> selectDate(FoverDateTab tab) async {
    if (tab == state.selectedTab) return;
    state = state.copyWith(selectedTab: tab, status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(tab.dateFor(DateTime.now()));
  }

  Future<void> retry() async {
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(state.selectedTab.dateFor(DateTime.now()));
  }

  Future<void> _loadMatchesForDate(DateTime date) async {
    final result = await _repository.fetchLeagueMatches(date);
    _handleResult(result);
  }

  void _handleResult(
    final ApiResult<List<LeagueInfo>> result, {
    bool refreshing = false,
  }) {
    if (result.isSuccess) {
      final leagues = result.data ?? const [];
      final nextStatus = leagues.isEmpty ? HomeStatus.empty : HomeStatus.loaded;
      state = state.copyWith(
        status: nextStatus,
        leagues: leagues,
        isRefreshing: false,
      );
    } else {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: result.error,
        isRefreshing: false,
      );
    }
  }
}
