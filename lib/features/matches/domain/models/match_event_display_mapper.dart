import 'package:fover/features/matches/domain/models/match_event_model.dart';

enum MatchEventDisplayType {
  goal,
  penaltyGoal,
  ownGoal,
  yellowCard,
  redCard,
  secondYellow,
  substitution,
  varCheck,
  goalConfirmed,
  goalCancelled,
  redCardConfirmed,
  redCardCancelled,
  penalty,
  missedPenalty,
  injury,
  kickoff,
  halfTime,
  fullTime,
  extraTime,
  penaltyShootout,
  unknown,
}

class MatchEventDisplayMapper {
  const MatchEventDisplayMapper._();

  static MatchEventDisplayType fromEvent(MatchEventInfo event) {
    final detail = event.detail.toLowerCase();
    final comments = event.description.toLowerCase();
    final raw = '$detail $comments'.trim();

    if (event.type == MatchEventType.goal) {
      return MatchEventDisplayType.goal;
    }

    if (event.type == MatchEventType.ownGoal) {
      return MatchEventDisplayType.ownGoal;
    }

    if (event.type == MatchEventType.penalty) {
      return MatchEventDisplayType.penalty;
    }

    if (event.type == MatchEventType.yellowCard) {
      if (raw.contains('second yellow')) {
        return MatchEventDisplayType.secondYellow;
      }
      return MatchEventDisplayType.yellowCard;
    }

    if (event.type == MatchEventType.redCard) {
      return MatchEventDisplayType.redCard;
    }

    if (event.type == MatchEventType.substitution) {
      return MatchEventDisplayType.substitution;
    }

    if (event.type == MatchEventType.varReview) {
      if (raw.contains('goal confirmed')) {
        return MatchEventDisplayType.goalConfirmed;
      }
      if (raw.contains('goal disallowed') || raw.contains('goal cancelled')) {
        return MatchEventDisplayType.goalCancelled;
      }
      if (raw.contains('red card confirmed')) {
        return MatchEventDisplayType.redCardConfirmed;
      }
      if (raw.contains('red card cancelled')) {
        return MatchEventDisplayType.redCardCancelled;
      }
      if (raw.contains('checking')) {
        return MatchEventDisplayType.varCheck;
      }
      return MatchEventDisplayType.varCheck;
    }

    if (event.type == MatchEventType.kickoff) {
      return MatchEventDisplayType.kickoff;
    }

    if (event.type == MatchEventType.halftime) {
      return MatchEventDisplayType.halfTime;
    }

    if (event.type == MatchEventType.fulltime) {
      return MatchEventDisplayType.fullTime;
    }

    if (raw.contains('penalty')) {
      return MatchEventDisplayType.penalty;
    }

    if (raw.contains('missed penalty')) {
      return MatchEventDisplayType.missedPenalty;
    }

    if (raw.contains('injury')) {
      return MatchEventDisplayType.injury;
    }

    if (raw.contains('extra time')) {
      return MatchEventDisplayType.extraTime;
    }

    if (raw.contains('penalty shootout')) {
      return MatchEventDisplayType.penaltyShootout;
    }

    return MatchEventDisplayType.unknown;
  }
}
