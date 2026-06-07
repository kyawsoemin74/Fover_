import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/home_repository_impl.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/providers/home_state.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._repository) : super(HomeState(status: HomeStatus.loading));

  final HomeRepository _repository;
  Timer? _liveRefreshTimer;
  bool _isRefreshing = false;

  Future<void> loadMatches() async {
    await _loadMatchesForDate(state.selectedDate);
  }

  Future<void> refresh() async {
    await _loadMatchesForDate(state.selectedDate, forceRefresh: true);
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

  Future<void> selectDate(DateTime date) async {
    if (DateUtils.isSameDay(date, state.selectedDate)) return;
    state = state.copyWith(selectedDate: date, status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(date);
  }

  Future<void> retry() async {
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(state.selectedDate);
  }

  Future<void> _loadMatchesForDate(DateTime date, {bool forceRefresh = false, bool periodic = false}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      if (!periodic) {
        state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
      }

      final result = await _repository.fetchLeagueMatches(date, forceRefresh: forceRefresh);
      if (periodic) {
        _handlePeriodicResult(result);
      } else {
        _handleResult(result);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Start the periodic live refresh. Call this when the Home page is visible.
  void startLiveRefresh() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (DateUtils.isSameDay(state.selectedDate, DateTime.now()) && state.status == HomeStatus.loaded) {
        await _refreshLiveMatches();
      }
    });
  }

  /// Stop the periodic live refresh. Call this when the Home page is not visible.
  void stopLiveRefresh() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = null;
  }

  Future<void> _refreshLiveMatches() async {
    if (_isRefreshing) {
      return;
    }

    await _loadMatchesForDate(state.selectedDate, forceRefresh: true, periodic: true);
  }

  void _handlePeriodicResult(ApiResult<List<LeagueInfo>> result) {
    if (!result.isSuccess) {
      return;
    }

    final leagues = result.data ?? const [];
    if (!_hasLeagueDataChanged(state.leagues, leagues)) {
      return;
    }

    final nextStatus = leagues.isEmpty ? HomeStatus.empty : HomeStatus.loaded;
    state = state.copyWith(
      status: nextStatus,
      leagues: leagues,
      isRefreshing: false,
    );
  }

  bool _hasLeagueDataChanged(List<LeagueInfo> current, List<LeagueInfo> next) {
    if (current.length != next.length) return true;
    for (var i = 0; i < current.length; i++) {
      final currentLeague = current[i];
      final nextLeague = next[i];
      if (currentLeague.id != nextLeague.id ||
          currentLeague.leagueName != nextLeague.leagueName ||
          currentLeague.countryFlagUrl != nextLeague.countryFlagUrl ||
          currentLeague.matches.length != nextLeague.matches.length) {
        return true;
      }

      for (var j = 0; j < currentLeague.matches.length; j++) {
        final currentMatch = currentLeague.matches[j];
        final nextMatch = nextLeague.matches[j];
        if (currentMatch.teamA != nextMatch.teamA ||
            currentMatch.teamB != nextMatch.teamB ||
            currentMatch.score != nextMatch.score ||
            currentMatch.status != nextMatch.status ||
            currentMatch.kickOffTime != nextMatch.kickOffTime ||
            currentMatch.teamALogoUrl != nextMatch.teamALogoUrl ||
            currentMatch.teamBLogoUrl != nextMatch.teamBLogoUrl) {
          return true;
        }
      }
    }
    return false;
  }

  void _handleResult(final ApiResult<List<LeagueInfo>> result) {
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

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }
}
