class MatchStatsInfo {
  const MatchStatsInfo({
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeAttacks,
    required this.awayAttacks,
    required this.homeDangerousAttacks,
    required this.awayDangerousAttacks,
    required this.homeFouls,
    required this.awayFouls,
    required this.homeOffsides,
    required this.awayOffsides,
    required this.homeYellowCards,
    required this.awayYellowCards,
    required this.homeRedCards,
    required this.awayRedCards,
  });

  final int homePossession;
  final int awayPossession;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final int homeCorners;
  final int awayCorners;
  final int homeAttacks;
  final int awayAttacks;
  final int homeDangerousAttacks;
  final int awayDangerousAttacks;
  final int homeFouls;
  final int awayFouls;
  final int homeOffsides;
  final int awayOffsides;
  final int homeYellowCards;
  final int awayYellowCards;
  final int homeRedCards;
  final int awayRedCards;

  bool get hasData => homePossession + awayPossession > 0 || homeShots + awayShots > 0;

  factory MatchStatsInfo.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? json;

    return MatchStatsInfo(
      homePossession: _statValue(stats, ['home_possession', 'possession_home', 'homePossession', 'possession_h']),
      awayPossession: _statValue(stats, ['away_possession', 'possession_away', 'awayPossession', 'possession_a']),
      homeShots: _statValue(stats, ['home_shots', 'shots_home', 'homeShots', 'shots_h']),
      awayShots: _statValue(stats, ['away_shots', 'shots_away', 'awayShots', 'shots_a']),
      homeShotsOnTarget: _statValue(stats, ['home_shots_on_target', 'shots_on_target_home', 'homeShotsOnTarget', 'shots_on_target_h']),
      awayShotsOnTarget: _statValue(stats, ['away_shots_on_target', 'shots_on_target_away', 'awayShotsOnTarget', 'shots_on_target_a']),
      homeCorners: _statValue(stats, ['home_corners', 'corners_home', 'homeCorners', 'corners_h']),
      awayCorners: _statValue(stats, ['away_corners', 'corners_away', 'awayCorners', 'corners_a']),
      homeAttacks: _statValue(stats, ['home_attacks', 'attacks_home', 'homeAttacks', 'attacks_h']),
      awayAttacks: _statValue(stats, ['away_attacks', 'attacks_away', 'awayAttacks', 'attacks_a']),
      homeDangerousAttacks: _statValue(stats, ['home_dangerous_attacks', 'dangerous_attacks_home', 'homeDangerousAttacks', 'dangerous_attacks_h']),
      awayDangerousAttacks: _statValue(stats, ['away_dangerous_attacks', 'dangerous_attacks_away', 'awayDangerousAttacks', 'dangerous_attacks_a']),
      homeFouls: _statValue(stats, ['home_fouls', 'fouls_home', 'homeFouls', 'fouls_h']),
      awayFouls: _statValue(stats, ['away_fouls', 'fouls_away', 'awayFouls', 'fouls_a']),
      homeOffsides: _statValue(stats, ['home_offsides', 'offsides_home', 'homeOffsides', 'offsides_h']),
      awayOffsides: _statValue(stats, ['away_offsides', 'offsides_away', 'awayOffsides', 'offsides_a']),
      homeYellowCards: _statValue(stats, ['home_yellow_cards', 'yellow_cards_home', 'homeYellowCards', 'yellow_cards_h']),
      awayYellowCards: _statValue(stats, ['away_yellow_cards', 'yellow_cards_away', 'awayYellowCards', 'yellow_cards_a']),
      homeRedCards: _statValue(stats, ['home_red_cards', 'red_cards_home', 'homeRedCards', 'red_cards_h']),
      awayRedCards: _statValue(stats, ['away_red_cards', 'red_cards_away', 'awayRedCards', 'red_cards_a']),
    );
  }

  factory MatchStatsInfo.empty() => const MatchStatsInfo(
        homePossession: 0,
        awayPossession: 0,
        homeShots: 0,
        awayShots: 0,
        homeShotsOnTarget: 0,
        awayShotsOnTarget: 0,
        homeCorners: 0,
        awayCorners: 0,
        homeAttacks: 0,
        awayAttacks: 0,
        homeDangerousAttacks: 0,
        awayDangerousAttacks: 0,
        homeFouls: 0,
        awayFouls: 0,
        homeOffsides: 0,
        awayOffsides: 0,
        homeYellowCards: 0,
        awayYellowCards: 0,
        homeRedCards: 0,
        awayRedCards: 0,
      );

  static int _statValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return _toInt(value);
    }
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
