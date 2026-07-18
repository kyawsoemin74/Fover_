import 'package:fover/features/matches/domain/models/goal_summary.dart';
import 'package:fover/features/matches/domain/models/goal_summary_result.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';

class GoalSummaryBuilder {
  const GoalSummaryBuilder();

  GoalSummaryResult build(
    List<MatchEventInfo> events, {
    required int homeTeamId,
    required int awayTeamId,
  }) {
    final homeScorers = <GoalSummary>[];
    final awayScorers = <GoalSummary>[];

    for (final event in events) {
      final isGoalEvent = event.type == MatchEventType.goal ||
          event.type == MatchEventType.ownGoal ||
          event.type == MatchEventType.penalty;

      if (!isGoalEvent) {
        continue;
      }

      final summary = GoalSummary(
        playerName: event.playerName,
        minute: event.minute,
        extraMinute: event.extraMinute,
        isPenalty: event.type == MatchEventType.penalty,
        isOwnGoal: event.type == MatchEventType.ownGoal,
      );

      if (event.teamId == 0) {
        continue;
      }

      if (event.teamId == homeTeamId) {
        homeScorers.add(summary);
      } else if (event.teamId == awayTeamId) {
        awayScorers.add(summary);
      }
    }

    return GoalSummaryResult(
      homeGoalScorers: homeScorers,
      awayGoalScorers: awayScorers,
    );
  }
}
