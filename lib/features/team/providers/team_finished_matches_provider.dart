import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/providers/team_finished_matches_state.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/repositories/team_repository.dart';

const int _maxFinishedMatchesToShow = 5;

final teamFinishedMatchesProvider = StateNotifierProvider.family<TeamFinishedMatchesNotifier, TeamFinishedMatchesState, int>(
  (ref, teamId) {
    return TeamFinishedMatchesNotifier(ref.watch(teamRepositoryProvider), teamId);
  },
);

class TeamFinishedMatchesNotifier extends StateNotifier<TeamFinishedMatchesState> {
  TeamFinishedMatchesNotifier(this._repository, this._teamId) : super(const TeamFinishedMatchesState());

  final TeamRepository _repository;
  final int _teamId;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.status == TeamFinishedMatchesStatus.loading) return;
    if (!forceRefresh && _shouldUseCache()) return;

    state = state.copyWith(
      status: forceRefresh
          ? TeamFinishedMatchesStatus.refreshing
          : TeamFinishedMatchesStatus.loading,
      errorMessage: null,
    );

    final result = await _repository.fetchFinishedMatches(_teamId);
    if (result.isSuccess) {
      final matches = _prepareMatches(result.data ?? const <TeamFinishedMatch>[]);
      final nextStatus = matches.isEmpty
          ? TeamFinishedMatchesStatus.empty
          : TeamFinishedMatchesStatus.loaded;
      state = state.copyWith(
        status: nextStatus,
        matches: matches,
        errorMessage: null,
        lastLoadedAt: DateTime.now(),
      );
    } else {
      state = state.copyWith(
        status: TeamFinishedMatchesStatus.error,
        errorMessage: result.error ?? 'Failed to load finished matches',
      );
    }
  }

  Future<void> refresh() async {
    await load(forceRefresh: true);
  }

  Future<void> retry() async {
    await load(forceRefresh: true);
  }

  List<TeamFinishedMatch> _prepareMatches(List<TeamFinishedMatch> matches) {
    final finishedMatches = matches.where(_isFinishedMatch).toList();
    finishedMatches.sort((a, b) => _compareDatesDescending(a, b));
    return finishedMatches.take(_maxFinishedMatchesToShow).toList();
  }

  bool _isFinishedMatch(TeamFinishedMatch match) {
    final normalizedStatus = (match.status ?? '').trim().toUpperCase();
    return normalizedStatus == 'FT' ||
        normalizedStatus == 'AET' ||
        normalizedStatus == 'PEN' ||
        normalizedStatus == 'FT_PEN' ||
        normalizedStatus == 'AWD' ||
        normalizedStatus == 'WO';
  }

  int _compareDatesDescending(TeamFinishedMatch left, TeamFinishedMatch right) {
    final leftDate = _parseDate(left.date ?? left.kickOffTime);
    final rightDate = _parseDate(right.date ?? right.kickOffTime);
    final comparison = rightDate.compareTo(leftDate);
    return comparison != 0 ? comparison : (left.matchId ?? 0).compareTo(right.matchId ?? 0);
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _shouldUseCache() {
    if (state.status != TeamFinishedMatchesStatus.loaded || state.matches.isEmpty) {
      return false;
    }

    final loadedAt = state.lastLoadedAt;
    if (loadedAt == null) return false;

    return DateTime.now().difference(loadedAt) < const Duration(minutes: 5);
  }
}
