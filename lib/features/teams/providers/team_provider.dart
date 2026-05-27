import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/teams/data/team_repository_impl.dart';
import 'package:fover/features/teams/domain/models/team_model.dart';
import 'package:fover/features/teams/domain/team_repository.dart';

enum TeamStatus { initial, loading, loaded, error }

class TeamState {
  const TeamState({
    this.status = TeamStatus.initial,
    this.team,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final TeamStatus status;
  final TeamInfo? team;
  final String? errorMessage;
  final bool isRefreshing;

  TeamState copyWith({
    TeamStatus? status,
    TeamInfo? team,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return TeamState(
      status: status ?? this.status,
      team: team ?? this.team,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(dioClient: DioClient());
});

final teamProvider = StateNotifierProvider.autoDispose<TeamNotifier, TeamState>((ref) {
  final repository = ref.watch(teamRepositoryProvider);
  return TeamNotifier(repository);
});

class TeamNotifier extends StateNotifier<TeamState> {
  TeamNotifier(this._repository) : super(const TeamState());

  final TeamRepository _repository;

  Future<void> loadTeam(int teamId) async {
    state = state.copyWith(status: TeamStatus.loading, errorMessage: null);
    final result = await _repository.fetchTeam(teamId);
    if (result.isSuccess) {
      state = state.copyWith(status: TeamStatus.loaded, team: result.data, errorMessage: null);
    } else {
      state = state.copyWith(status: TeamStatus.error, errorMessage: result.error);
    }
  }

  Future<void> refreshTeam(int teamId) async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchTeam(teamId, forceRefresh: true);
    if (result.isSuccess) {
      state = state.copyWith(status: TeamStatus.loaded, team: result.data, isRefreshing: false);
    } else {
      state = state.copyWith(status: TeamStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
