import 'package:flutter/foundation.dart';

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

    // minute/extra parsing: support strings like "45+3'", nested time objects, and separate extra fields
    final minuteSource = json['elapsed'] ?? json['minute'] ?? json['time'] ?? json['time_elapsed'] ?? json['timeElapsed'];
    final extraSource = json['extra'] ?? json['extra_minute'] ?? json['injury_time'] ?? json['time_extra'] ?? json['timeExtra'];
    final _minuteParse = _parseMinute(minuteSource, extraSource);
    final minute = _minuteParse.item1;
    final extraMinute = _minuteParse.item2;

    final teamId = _toInt(json['team_id'] ?? json['teamId'] ?? json['team']?['id']);
    final teamName = (json['team_name'] ?? json['team_name'] ?? json['team']?['name'] ?? json['team']?.toString())?.toString() ?? '';

    // player can be a string or an object
    String playerName = '';
    final playerRaw = json['player'] ?? json['player_name'] ?? json['player_name'];
    if (playerRaw is Map) {
      playerName = (playerRaw['name'] ?? playerRaw['player_name'] ?? playerRaw['full_name'] ?? '')?.toString() ?? '';
    } else if (playerRaw != null) {
      playerName = playerRaw.toString();
    }

    final playerNumber = _nullableInt(json['player_number'] ?? json['number'] ?? json['shirt_number'] ?? (playerRaw is Map ? playerRaw['number'] : null));
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

  // Returns (minute, extraMinute)
  static _MinuteTuple _parseMinute(dynamic minuteSource, dynamic extraSource) {
    int minute = 0;
    int extra = 0;
    try {
      if (minuteSource is Map) {
        minute = _toInt(minuteSource['minute'] ?? minuteSource['elapsed'] ?? minuteSource['time'] ?? minuteSource['time_elapsed'] ?? minuteSource['timeElapsed'] ?? minuteSource['m'] ?? 0);
        extra = _toInt(minuteSource['extra'] ?? minuteSource['injury_time'] ?? minuteSource['extra_minute'] ?? minuteSource['time_extra'] ?? minuteSource['timeExtra'] ?? 0);
      } else if (minuteSource is String) {
        // e.g. "45+3'" or "45+3"
        final cleaned = minuteSource.replaceAll("'", '').trim();
        if (cleaned.contains('+')) {
          final parts = cleaned.split('+');
          minute = int.tryParse(parts.first.trim()) ?? 0;
          extra = int.tryParse(parts.last.trim()) ?? 0;
        } else {
          minute = int.tryParse(cleaned) ?? 0;
        }
      } else if (minuteSource is int) {
        minute = minuteSource;
      }

      if (extra == 0) {
        if (extraSource is String) {
          extra = int.tryParse(extraSource.replaceAll("'", '')) ?? 0;
        } else if (extraSource is int) {
          extra = extraSource;
        } else if (extraSource is Map) {
          extra = _toInt(extraSource['extra'] ?? extraSource['injury_time'] ?? extraSource['extra_minute'] ?? 0);
        }
      }
    } catch (_) {}
    return _MinuteTuple(minute, extra);
  }

}

class _MinuteTuple {
  _MinuteTuple(this.item1, this.item2);
  final int item1;
  final int item2;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _nullableInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

MatchEventType _parseType(String rawType, String detail) {
  final normalized = '${rawType.toLowerCase()} ${detail.toLowerCase()}';
  if (normalized.contains('own goal')) return MatchEventType.ownGoal;
  if (normalized.contains('penalty')) return MatchEventType.penalty;
  if (normalized.contains('yellow card') || normalized.contains('yellow')) return MatchEventType.yellowCard;
  if (normalized.contains('red card') || normalized.contains('red')) return MatchEventType.redCard;
  if (normalized.contains('substitution') || normalized.contains('subst') || normalized.contains('sub ')) return MatchEventType.substitution;
  if (normalized.contains('var') || normalized.contains('video assistant referee')) return MatchEventType.varReview;
  if (normalized.contains('kick off') || normalized.contains('kickoff')) return MatchEventType.kickoff;
  if (normalized.contains('half time') || normalized.contains('ht')) return MatchEventType.halftime;
  if (normalized.contains('full time') || normalized.contains('ft')) return MatchEventType.fulltime;
  if (normalized.contains('goal')) return MatchEventType.goal;
  debugPrint('[MatchEventInfo] unknown event type rawType="$rawType" detail="$detail" normalized="$normalized"');
  return MatchEventType.unknown;
}

MatchEventPeriod _parsePeriod(String? rawPeriod, int minute) {
  final normalized = rawPeriod?.toLowerCase() ?? '';
  if (normalized.contains('first')) return MatchEventPeriod.firstHalf;
  if (normalized.contains('second')) return MatchEventPeriod.secondHalf;
  if (normalized.contains('extra')) return MatchEventPeriod.extraTime;
  if (normalized.contains('penalty')) return MatchEventPeriod.penaltyShootout;
  if (minute > 90) return MatchEventPeriod.extraTime;
  if (minute > 45) return MatchEventPeriod.secondHalf;
  return MatchEventPeriod.firstHalf;
}

