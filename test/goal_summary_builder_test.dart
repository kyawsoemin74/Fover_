import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/matches/domain/builders/goal_summary_builder.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';

void main() {
  group('GoalSummaryBuilder', () {
    test('routes events to home or away only when team ids match the provided home/away ids', () {
      final builder = GoalSummaryBuilder();
      final events = <MatchEventInfo>[
        _event(playerName: 'Home scorer', teamId: 33, type: MatchEventType.goal),
        _event(playerName: 'Away scorer', teamId: 40, type: MatchEventType.goal),
        _event(playerName: 'Unmapped scorer', teamId: 99, type: MatchEventType.goal),
      ];

      final summary = builder.build(
        events,
        homeTeamId: 33,
        awayTeamId: 40,
      );

      expect(summary.homeGoalScorers.map((scorer) => scorer.playerName), ['Home scorer']);
      expect(summary.awayGoalScorers.map((scorer) => scorer.playerName), ['Away scorer']);
    });
  });
}

MatchEventInfo _event({
  required String playerName,
  required int teamId,
  required MatchEventType type,
}) {
  return MatchEventInfo(
    minute: 12,
    extraMinute: 0,
    period: MatchEventPeriod.firstHalf,
    teamId: teamId,
    teamName: 'Team $teamId',
    playerName: playerName,
    playerNumber: 10,
    type: type,
    detail: '',
    description: '',
    assistName: null,
    raw: const {},
  );
}
