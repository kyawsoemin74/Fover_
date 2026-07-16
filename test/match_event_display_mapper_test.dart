import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/domain/models/match_event_display_mapper.dart';

void main() {
  group('MatchEventDisplayMapper', () {
    MatchEventInfo buildEvent({
      MatchEventType type = MatchEventType.unknown,
      String detail = '',
      String description = '',
    }) {
      return MatchEventInfo(
        minute: 45,
        extraMinute: 0,
        period: MatchEventPeriod.firstHalf,
        teamId: 1,
        teamName: 'Home',
        playerName: 'Player',
        playerNumber: 10,
        type: type,
        detail: detail,
        description: description,
        assistName: null,
        raw: const {},
      );
    }

    test('maps a goal event to goal', () {
      final event = buildEvent(type: MatchEventType.goal);
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.goal);
    });

    test('maps a yellow card event to yellowCard', () {
      final event = buildEvent(type: MatchEventType.yellowCard, detail: 'Yellow Card');
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.yellowCard);
    });

    test('maps a substitution event to substitution', () {
      final event = buildEvent(type: MatchEventType.substitution);
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.substitution);
    });

    test('maps a VAR checking event to varCheck', () {
      final event = buildEvent(type: MatchEventType.varReview, detail: 'Checking');
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.varCheck);
    });

    test('maps a goal confirmed event to goalConfirmed', () {
      final event = buildEvent(type: MatchEventType.varReview, detail: 'Goal Confirmed');
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.goalConfirmed);
    });

    test('maps an unknown event to unknown', () {
      final event = buildEvent();
      expect(MatchEventDisplayMapper.fromEvent(event), MatchEventDisplayType.unknown);
    });
  });
}
