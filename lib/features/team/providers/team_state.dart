import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';

enum TeamStatus { initial, loading, loaded, error }

enum TeamMatchesStatus { initial, loading, loaded, empty, error }

enum TeamStandingsStatus { initial, loading, loaded, empty, error }

enum TeamSquadStatus { initial, loading, loaded, empty, error }

class TeamState {
  const TeamState({
    this.status = TeamStatus.initial,
    this.team,
    this.errorMessage,
    this.matchesStatus = TeamMatchesStatus.initial,
    this.matches = const [],
    this.matchesErrorMessage,
    this.standingsStatus = TeamStandingsStatus.initial,
    this.standings = const [],
    this.standingsErrorMessage,
    this.squadStatus = TeamSquadStatus.initial,
    this.squad,
    this.squadError,
  });

  final TeamStatus status;
  final TeamModel? team;
  final String? errorMessage;
  final TeamMatchesStatus matchesStatus;
  final List<MatchInfo> matches;
  final String? matchesErrorMessage;
  final TeamStandingsStatus standingsStatus;
  final List<StandingInfo> standings;
  final String? standingsErrorMessage;
  final TeamSquadStatus squadStatus;
  final TeamSquadInfo? squad;
  final String? squadError;

  TeamState copyWith({
    TeamStatus? status,
    TeamModel? team,
    String? errorMessage,
    TeamMatchesStatus? matchesStatus,
    List<MatchInfo>? matches,
    String? matchesErrorMessage,
    TeamStandingsStatus? standingsStatus,
    List<StandingInfo>? standings,
    String? standingsErrorMessage,
    TeamSquadStatus? squadStatus,
    TeamSquadInfo? squad,
    String? squadError,
  }) {
    return TeamState(
      status: status ?? this.status,
      team: team ?? this.team,
      errorMessage: errorMessage ?? this.errorMessage,
      matchesStatus: matchesStatus ?? this.matchesStatus,
      matches: matches ?? this.matches,
      matchesErrorMessage: matchesErrorMessage ?? this.matchesErrorMessage,
      standingsStatus: standingsStatus ?? this.standingsStatus,
      standings: standings ?? this.standings,
      standingsErrorMessage: standingsErrorMessage ?? this.standingsErrorMessage,
      squadStatus: squadStatus ?? this.squadStatus,
      squad: squad ?? this.squad,
      squadError: squadError ?? this.squadError,
    );
  }
}
