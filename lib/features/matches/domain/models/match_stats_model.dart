import 'statistics_item.dart';

class MatchStatsInfo {
  const MatchStatsInfo({
    this.homePossession = 0,
    this.awayPossession = 0,
    this.homeShots = 0,
    this.awayShots = 0,
    this.homeShotsOnTarget = 0,
    this.awayShotsOnTarget = 0,
    this.homeCorners = 0,
    this.awayCorners = 0,
    this.homeAttacks = 0,
    this.awayAttacks = 0,
    this.homeDangerousAttacks = 0,
    this.awayDangerousAttacks = 0,
    this.homeFouls = 0,
    this.awayFouls = 0,
    this.homeOffsides = 0,
    this.awayOffsides = 0,
    this.homeYellowCards = 0,
    this.awayYellowCards = 0,
    this.homeRedCards = 0,
    this.awayRedCards = 0,
    this.items,
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
  final List<StatisticsItem>? items;

  factory MatchStatsInfo.empty() => const MatchStatsInfo(items: <StatisticsItem>[]);

  bool get hasData {
    if (homePossession + awayPossession > 0) return true;
    if (homeShots + awayShots > 0) return true;
    if (items != null && items!.isNotEmpty) {
      for (final it in items!) {
        if (_toNumFlexible(it.homeValue) > 0 || _toNumFlexible(it.awayValue) > 0) return true;
      }
    }
    return false;
  }

  factory MatchStatsInfo.fromJson(Map<String, dynamic> json) {
    // New API: statistics is a list of metric entries
    final statsList = json['statistics'] as List<dynamic>?;
    if (statsList != null && statsList.isNotEmpty) {
      final items = statsList
          .whereType<Map<String, dynamic>>()
          .map(StatisticsItem.fromJson)
          .toList();

      // default accumulators
      var homePossession = 0;
      var awayPossession = 0;
      var homeShots = 0;
      var awayShots = 0;
      var homeShotsOnTarget = 0;
      var awayShotsOnTarget = 0;
      var homeCorners = 0;
      var awayCorners = 0;
      var homeAttacks = 0;
      var awayAttacks = 0;
      var homeDangerousAttacks = 0;
      var awayDangerousAttacks = 0;
      var homeFouls = 0;
      var awayFouls = 0;
      var homeOffsides = 0;
      var awayOffsides = 0;
      var homeYellowCards = 0;
      var awayYellowCards = 0;
      var homeRedCards = 0;
      var awayRedCards = 0;

      for (final item in items) {
        final key = item.dataName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
        final h = _toIntFlexible(item.homeValue);
        final a = _toIntFlexible(item.awayValue);

        if (key.contains('possession') || key.contains('ball_possession')) {
          homePossession = h;
          awayPossession = a;
        } else if (key.contains('shots_on') || key.contains('shots_on_goal') || key.contains('shots_on_target')) {
          homeShotsOnTarget = h;
          awayShotsOnTarget = a;
        } else if (key == 'total_shots' || key == 'shots_total' || key == 'shots_total_home' || key == 'shots_total_away') {
          homeShots = h;
          awayShots = a;
        } else if (key.contains('shots') && !key.contains('on') && !key.contains('off')) {
          // Map remaining 'shots' that are not 'shots_on' or 'shots_off' to total shots
          homeShots = h;
          awayShots = a;
        } else if (key.contains('corner')) {
          homeCorners = h;
          awayCorners = a;
        } else if (key.contains('danger') || key.contains('dangerous')) {
          homeDangerousAttacks = h;
          awayDangerousAttacks = a;
        } else if (key.contains('attack')) {
          homeAttacks = h;
          awayAttacks = a;
        } else if (key.contains('foul')) {
          homeFouls = h;
          awayFouls = a;
        } else if (key.contains('offs') || key.contains('offside')) {
          homeOffsides = h;
          awayOffsides = a;
        } else if (key.contains('yellow')) {
          homeYellowCards = h;
          awayYellowCards = a;
        } else if (key.contains('red')) {
          homeRedCards = h;
          awayRedCards = a;
        }
      }

      return MatchStatsInfo(
        homePossession: homePossession,
        awayPossession: awayPossession,
        homeShots: homeShots,
        awayShots: awayShots,
        homeShotsOnTarget: homeShotsOnTarget,
        awayShotsOnTarget: awayShotsOnTarget,
        homeCorners: homeCorners,
        awayCorners: awayCorners,
        homeAttacks: homeAttacks,
        awayAttacks: awayAttacks,
        homeDangerousAttacks: homeDangerousAttacks,
        awayDangerousAttacks: awayDangerousAttacks,
        homeFouls: homeFouls,
        awayFouls: awayFouls,
        homeOffsides: homeOffsides,
        awayOffsides: awayOffsides,
        homeYellowCards: homeYellowCards,
        awayYellowCards: awayYellowCards,
        homeRedCards: homeRedCards,
        awayRedCards: awayRedCards,
        items: items,
      );
    }

    // Backwards-compatible behavior: support legacy 'stats' map or flat keys
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

  static int _statValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return _toIntFlexible(value);
    }
    return 0;
  }

  static int _toIntFlexible(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      var s = value.trim();
      // remove percent sign
      if (s.endsWith('%')) {
        s = s.substring(0, s.length - 1).trim();
      }
      // remove commas
      s = s.replaceAll(',', '');
      final d = double.tryParse(s);
      if (d != null) return d.round();
      return int.tryParse(s) ?? 0;
    }
    return 0;
  }

  static double _toNumFlexible(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      var s = value.trim();
      if (s.endsWith('%')) s = s.substring(0, s.length - 1).trim();
      s = s.replaceAll(',', '');
      final d = double.tryParse(s);
      if (d != null) return d;
      return 0.0;
    }
    return 0.0;
  }
}
