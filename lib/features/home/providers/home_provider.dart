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
  int _requestSequence = 0;
  final Map<String, List<LeagueInfo>> _dateCache = {};

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
    final requestId = ++_requestSequence;
    final normalizedDate = _dateKey(date);
    final cachedLeagues = _dateCache[normalizedDate];

    if (cachedLeagues != null) {
      state = state.copyWith(
        selectedDate: date,
        status: cachedLeagues.isEmpty ? HomeStatus.empty : HomeStatus.loaded,
        leagues: cachedLeagues,
        errorMessage: null,
        isRefreshing: false,
      );
      return;
    }

    state = state.copyWith(
      selectedDate: date,
      status: HomeStatus.loading,
      errorMessage: null,
    );
    await _loadMatchesForDate(date, requestId: requestId, setLoading: false);
  }

  Future<void> retry() async {
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    await _loadMatchesForDate(state.selectedDate);
  }

  Future<void> _loadMatchesForDate(
    DateTime date, {
    bool forceRefresh = false,
    bool periodic = false,
    int? requestId,
    bool setLoading = true,
  }) async {
    final normalizedDate = _dateKey(date);
    final activeRequestId = requestId ?? ++_requestSequence;

    if (!forceRefresh) {
      final cachedLeagues = _dateCache[normalizedDate];
      if (cachedLeagues != null) {
        if (_isLatestRequest(activeRequestId)) {
          _applyLoadedLeagues(cachedLeagues);
        }
        return;
      }
    }

    if (setLoading && !periodic) {
      state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    }

    final result = await _repository.fetchLeagueMatches(date, forceRefresh: forceRefresh);
    if (!_isLatestRequest(activeRequestId)) {
      return;
    }

    if (periodic) {
      _handlePeriodicResult(result, requestDate: normalizedDate);
    } else {
      _handleResult(result, requestDate: normalizedDate);
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
    await _loadMatchesForDate(state.selectedDate, forceRefresh: true, periodic: true);
  }

  void _handlePeriodicResult(ApiResult<List<LeagueInfo>> result, {required String requestDate}) {
    if (!result.isSuccess) {
      return;
    }

    final leagues = result.data ?? const [];
    _dateCache[requestDate] = leagues;
    if (!_hasLeagueDataChanged(state.leagues, leagues)) {
      return;
    }

    _applyLoadedLeagues(leagues);
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

  void _handleResult(final ApiResult<List<LeagueInfo>> result, {required String requestDate}) {
    if (result.isSuccess) {
      final leagues = result.data ?? const [];
      _dateCache[requestDate] = leagues;
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

  void _applyLoadedLeagues(List<LeagueInfo> leagues) {
    final nextStatus = leagues.isEmpty ? HomeStatus.empty : HomeStatus.loaded;
    state = state.copyWith(
      status: nextStatus,
      leagues: leagues,
      isRefreshing: false,
    );
  }

  bool _isLatestRequest(int requestId) {
    return requestId == _requestSequence;
  }

  String _dateKey(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }
}
