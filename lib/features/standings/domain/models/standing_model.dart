class StandingInfo {
  const StandingInfo({
    required this.leagueId,
    required this.season,
    this.groupName,
    this.description,
    this.status,
    this.form,
    required this.position,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  final int leagueId;
  final String season;
  final String? groupName;
  final String? description;
  final String? status;
  final String? form;
  final int position;
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  StandingInfo copyWith({
    int? leagueId,
    String? season,
    String? groupName,
    String? description,
    String? status,
    String? form,
    int? position,
    int? teamId,
    String? teamName,
    String? teamLogo,
    int? points,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? goalsFor,
    int? goalsAgainst,
    int? goalDifference,
  }) {
    return StandingInfo(
      leagueId: leagueId ?? this.leagueId,
      season: season ?? this.season,
      groupName: groupName ?? this.groupName,
      description: description ?? this.description,
      status: status ?? this.status,
      form: form ?? this.form,
      position: position ?? this.position,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      points: points ?? this.points,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      goalDifference: goalDifference ?? this.goalDifference,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandingInfo &&
          runtimeType == other.runtimeType &&
          leagueId == other.leagueId &&
          season == other.season &&
          groupName == other.groupName &&
          description == other.description &&
          status == other.status &&
          form == other.form &&
          position == other.position &&
          teamId == other.teamId &&
          teamName == other.teamName &&
          teamLogo == other.teamLogo &&
          points == other.points &&
          played == other.played &&
          won == other.won &&
          drawn == other.drawn &&
          lost == other.lost &&
          goalsFor == other.goalsFor &&
          goalsAgainst == other.goalsAgainst &&
          goalDifference == other.goalDifference;

  @override
  int get hashCode => Object.hash(
        leagueId,
        season,
        groupName,
        description,
        status,
        form,
        position,
        teamId,
        teamName,
        teamLogo,
        points,
        played,
        won,
        drawn,
        lost,
        goalsFor,
        goalsAgainst,
        goalDifference,
      );
}
