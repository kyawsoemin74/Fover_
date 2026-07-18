import 'package:fover/features/matches/domain/models/goal_summary.dart';

class GoalSummaryResult {
  const GoalSummaryResult({
    this.homeGoalScorers = const <GoalSummary>[],
    this.awayGoalScorers = const <GoalSummary>[],
  });

  final List<GoalSummary> homeGoalScorers;
  final List<GoalSummary> awayGoalScorers;
}
