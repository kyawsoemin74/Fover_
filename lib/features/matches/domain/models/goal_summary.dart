class GoalSummary {
  const GoalSummary({
    required this.playerName,
    required this.minute,
    required this.extraMinute,
    required this.isPenalty,
    required this.isOwnGoal,
  });

  final String playerName;
  final int minute;
  final int extraMinute;
  final bool isPenalty;
  final bool isOwnGoal;
}
