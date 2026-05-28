enum MatchEventType {
  goal,
  ownGoal,
  penalty,
  yellowCard,
  redCard,
  substitution,
  varReview,
  kickoff,
  halftime,
  fulltime,
  unknown,
}

enum MatchEventPeriod {
  firstHalf,
  secondHalf,
  extraTime,
  penaltyShootout,
  unknown,
}

class MatchEventInfo {
  const MatchEventInfo({
    required this.minute,
    required this.extraMinute,
    required this.period,
    required this.teamId,
    required this.teamName,
    required this.playerName,
    required this.playerNumber,
    required this.type,
    required this.detail,
    required this.description,
    required this.assistName,
    required this.raw,
  });

  final int minute;
  final int extraMinute;
  final MatchEventPeriod period;
  final int teamId;
  final String teamName;
  final String playerName;
  final int? playerNumber;
  final MatchEventType type;
  final String detail;
  final String description;
  final String? assistName;
  final Map<String, dynamic> raw;

  factory MatchEventInfo.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? json['event_type'] ?? json['detail'])?.toString() ?? '';
    final rawDetail = (json['detail'] ?? json['event_detail'] ?? json['description'])?.toString() ?? '';
    final minute = _toInt(json['elapsed'] ?? json['minute'] ?? json['time'] ?? 0);
    final extraMinute = _toInt(json['extra'] ?? json['extra_minute'] ?? json['injury_time'] ?? 0);
    final teamId = _toInt(json['team_id'] ?? json['teamId'] ?? json['team']?['id']);
    final teamName = (json['team_name'] ?? json['team_name'] ?? json['team']?['name'] ?? json['team']?.toString())?.toString() ?? '';
    final playerName = (json['player'] ?? json['player_name'] ?? json['player_name'] ?? '')?.toString() ?? '';
    final playerNumber = _nullableInt(json['player_number'] ?? json['number'] ?? json['shirt_number']);
    final assistName = (json['assist'] ?? json['assist_name'] ?? '')?.toString();
    final description = (json['comments'] ?? json['comment'] ?? json['description'] ?? '')?.toString() ?? '';

    return MatchEventInfo(
      minute: minute,
      extraMinute: extraMinute,
      period: _parsePeriod(json['period']?.toString(), minute),
      teamId: teamId,
      teamName: teamName,
      playerName: playerName,
      playerNumber: playerNumber,
      type: _parseType(rawType, rawDetail),
      detail: rawDetail.isNotEmpty ? rawDetail : rawType,
      description: description,
      assistName: assistName?.isEmpty == true ? null : assistName,
      raw: Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(json)),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static MatchEventType _parseType(String rawType, String detail) {
    final normalized = '${rawType.toLowerCase()} ${detail.toLowerCase()}';
    if (normalized.contains('own goal')) return MatchEventType.ownGoal;
    if (normalized.contains('penalty')) return MatchEventType.penalty;
    if (normalized.contains('yellow card') || normalized.contains('yellow')) return MatchEventType.yellowCard;
    if (normalized.contains('red card') || normalized.contains('red')) return MatchEventType.redCard;
    if (normalized.contains('substitution') || normalized.contains('sub')) return MatchEventType.substitution;
    if (normalized.contains('var') || normalized.contains('video assistant referee')) return MatchEventType.varReview;
    if (normalized.contains('kick off') || normalized.contains('kickoff')) return MatchEventType.kickoff;
    if (normalized.contains('half time') || normalized.contains('ht')) return MatchEventType.halftime;
    if (normalized.contains('full time') || normalized.contains('ft')) return MatchEventType.fulltime;
    if (normalized.contains('goal')) return MatchEventType.goal;
    return MatchEventType.unknown;
  }

  static MatchEventPeriod _parsePeriod(String? rawPeriod, int minute) {
    final normalized = rawPeriod?.toLowerCase() ?? '';
    if (normalized.contains('first')) return MatchEventPeriod.firstHalf;
    if (normalized.contains('second')) return MatchEventPeriod.secondHalf;
    if (normalized.contains('extra')) return MatchEventPeriod.extraTime;
    if (normalized.contains('penalty')) return MatchEventPeriod.penaltyShootout;
    if (minute > 90) return MatchEventPeriod.extraTime;
    if (minute > 45) return MatchEventPeriod.secondHalf;
    return MatchEventPeriod.firstHalf;
  }
}
