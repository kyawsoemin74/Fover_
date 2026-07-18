import 'package:fover/features/team/models/team_finished_match.dart';

enum TeamFinishedMatchesStatus { initial, loading, refreshing, loaded, empty, error }

class TeamFinishedMatchesState {
  const TeamFinishedMatchesState({
    this.status = TeamFinishedMatchesStatus.initial,
    this.matches = const [],
    this.errorMessage,
    this.lastLoadedAt,
  });

  final TeamFinishedMatchesStatus status;
  final List<TeamFinishedMatch> matches;
  final String? errorMessage;
  final DateTime? lastLoadedAt;

  TeamFinishedMatchesState copyWith({
    TeamFinishedMatchesStatus? status,
    List<TeamFinishedMatch>? matches,
    String? errorMessage,
    DateTime? lastLoadedAt,
  }) {
    return TeamFinishedMatchesState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}
