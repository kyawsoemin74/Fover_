import 'package:fover/features/team/models/team_model.dart';

enum TeamStatus { initial, loading, loaded, error }

class TeamState {
  const TeamState({
    this.status = TeamStatus.initial,
    this.team,
    this.errorMessage,
  });

  final TeamStatus status;
  final TeamModel? team;
  final String? errorMessage;

  TeamState copyWith({
    TeamStatus? status,
    TeamModel? team,
    String? errorMessage,
  }) {
    return TeamState(
      status: status ?? this.status,
      team: team ?? this.team,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
