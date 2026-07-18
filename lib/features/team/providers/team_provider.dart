import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/providers/team_state.dart';
import 'package:fover/features/team/repositories/team_repository.dart';
import 'package:fover/features/team/repositories/team_repository_impl.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final teamProvider =
    StateNotifierProvider.autoDispose.family<TeamNotifier, TeamState, int>((
      ref,
      teamId,
    ) {
      final repository = ref.watch(teamRepositoryProvider);
      final notifier = TeamNotifier(repository);
      notifier.loadTeam(teamId);
      return notifier;
    });

class TeamNotifier extends StateNotifier<TeamState> {
  TeamNotifier(this._repository) : super(const TeamState());

  final TeamRepository _repository;
  bool _isLoadingStandings = false;
  bool _isLoadingSquad = false;

  Future<void> loadTeam(int teamId) async {
    state = state.copyWith(status: TeamStatus.loading, errorMessage: null);
    final result = await _repository.fetchTeam(teamId);
    if (result.isSuccess) {
      state = state.copyWith(
        status: TeamStatus.loaded,
        team: result.data,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        status: TeamStatus.error,
        errorMessage: result.error ?? 'Failed to load team profile',
      );
    }
  }

  Future<void> loadMatches(int teamId) async {
    state = state.copyWith(
      matchesStatus: TeamMatchesStatus.loading,
      matchesErrorMessage: null,
    );
    final result = await _repository.fetchTeamMatches(teamId);
    if (result.isSuccess) {
      final matches = result.data ?? const <MatchInfo>[];
      final nextStatus = matches.isEmpty ? TeamMatchesStatus.empty : TeamMatchesStatus.loaded;
      state = state.copyWith(
        matchesStatus: nextStatus,
        matches: matches,
        matchesErrorMessage: null,
      );
    } else {
      state = state.copyWith(
        matchesStatus: TeamMatchesStatus.error,
        matchesErrorMessage: result.error ?? 'Failed to load team matches',
      );
    }
  }

  Future<void> loadStandings(int teamId) async {
    if (_isLoadingStandings) {
      return;
    }

    _isLoadingStandings = true;
    state = state.copyWith(
      standingsStatus: TeamStandingsStatus.loading,
      standingsErrorMessage: null,
    );
    final result = await _repository.fetchTeamStandings(teamId);
    _isLoadingStandings = false;
    if (result.isSuccess) {
      final standings = result.data ?? const <StandingInfo>[];
      final nextStatus = standings.isEmpty ? TeamStandingsStatus.empty : TeamStandingsStatus.loaded;
      state = state.copyWith(
        standingsStatus: nextStatus,
        standings: standings,
        standingsErrorMessage: null,
      );
    } else {
      state = state.copyWith(
        standingsStatus: TeamStandingsStatus.error,
        standingsErrorMessage: result.error ?? 'Failed to load team standings',
      );
    }
  }

  Future<void> loadSquad(int teamId) async {
    if (_isLoadingSquad) {
      return;
    }

    _isLoadingSquad = true;
    state = state.copyWith(
      squadStatus: TeamSquadStatus.loading,
      squadError: null,
    );
    final result = await _repository.fetchTeamSquad(teamId);
    _isLoadingSquad = false;
    if (result.isSuccess) {
      final squad = result.data;
      final nextStatus = squad == null || squad.players.isEmpty
          ? TeamSquadStatus.empty
          : TeamSquadStatus.loaded;
      state = state.copyWith(
        squadStatus: nextStatus,
        squad: squad,
        squadError: null,
      );
    } else {
      state = state.copyWith(
        squadStatus: TeamSquadStatus.error,
        squadError: result.error ?? 'Failed to load team squad',
      );
    }
  }

  Future<void> reload(int teamId) async {
    await loadTeam(teamId);
  }
}
