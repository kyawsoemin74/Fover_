import 'package:flutter/material.dart';

class LeagueStandingRule {
  const LeagueStandingRule({
    required this.label,
    required this.minPosition,
    required this.maxPosition,
    required this.color,
  });

  final String label;
  final int minPosition;
  final int maxPosition;
  final Color color;
}

class LeagueStandingRules {
  const LeagueStandingRules._();

  static List<LeagueStandingRule> forLeagueId(int leagueId) {
    switch (leagueId) {
      case 39:
        return const [
          LeagueStandingRule(label: 'Champions League', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Europa League', minPosition: 5, maxPosition: 5, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Conference League', minPosition: 6, maxPosition: 6, color: Color(0xFF38BDF8)),
          LeagueStandingRule(label: 'Relegation', minPosition: 18, maxPosition: 20, color: Color(0xFFF43F5E)),
        ];
      case 140:
        return const [
          LeagueStandingRule(label: 'Champions League', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Europa League', minPosition: 5, maxPosition: 6, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Conference League', minPosition: 7, maxPosition: 7, color: Color(0xFF38BDF8)),
          LeagueStandingRule(label: 'Relegation', minPosition: 18, maxPosition: 20, color: Color(0xFFF43F5E)),
        ];
      case 78:
        return const [
          LeagueStandingRule(label: 'Champions League', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Europa League', minPosition: 5, maxPosition: 5, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Conference League', minPosition: 6, maxPosition: 6, color: Color(0xFF38BDF8)),
          LeagueStandingRule(label: 'Relegation', minPosition: 15, maxPosition: 18, color: Color(0xFFF43F5E)),
        ];
      case 135:
        return const [
          LeagueStandingRule(label: 'Champions League', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Europa League', minPosition: 5, maxPosition: 5, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Conference League', minPosition: 6, maxPosition: 6, color: Color(0xFF38BDF8)),
          LeagueStandingRule(label: 'Relegation', minPosition: 18, maxPosition: 20, color: Color(0xFFF43F5E)),
        ];
      case 71:
        return const [
          LeagueStandingRule(label: 'Libertadores', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Sudamericana', minPosition: 5, maxPosition: 6, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Relegation', minPosition: 17, maxPosition: 20, color: Color(0xFFF43F5E)),
        ];
      case 72:
        return const [
          LeagueStandingRule(label: 'Promotion', minPosition: 1, maxPosition: 4, color: Color(0xFF22C55E)),
          LeagueStandingRule(label: 'Relegation Playoff', minPosition: 15, maxPosition: 16, color: Color(0xFFF59E0B)),
          LeagueStandingRule(label: 'Relegation', minPosition: 17, maxPosition: 20, color: Color(0xFFF43F5E)),
        ];
      default:
        return const [];
    }
  }

  static LeagueStandingRule? resolve(int leagueId, int position) {
    for (final rule in forLeagueId(leagueId)) {
      if (position >= rule.minPosition && position <= rule.maxPosition) {
        return rule;
      }
    }
    return null;
  }
}
