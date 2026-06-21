import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
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

  Future<void> reload(int teamId) async {
    await loadTeam(teamId);
  }
}
