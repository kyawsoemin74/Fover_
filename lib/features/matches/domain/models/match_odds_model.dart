class MatchOddsInfo {
  const MatchOddsInfo({
    required this.source,
    required this.odds,
    required this.cached,
    required this.matchStarted,
    required this.reason,
  });

  final String source;
  final List<dynamic> odds;
  final bool cached;
  final bool matchStarted;
  final String reason;

  factory MatchOddsInfo.fromJson(Map<String, dynamic> json) {
    return MatchOddsInfo(
      source: json['source'] as String? ?? '',
      odds: (json['odds'] as List<dynamic>?) ?? const [],
      cached: json['cached'] as bool? ?? false,
      matchStarted: json['match_started'] as bool? ?? json['matchStarted'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );
  }
}
