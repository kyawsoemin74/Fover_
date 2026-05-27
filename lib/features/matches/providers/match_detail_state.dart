import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';

enum MatchDetailStatus { initial, loading, loaded, refreshing, error }

class MatchDetailState {
  const MatchDetailState({
    this.status = MatchDetailStatus.initial,
    this.matchDetail,
    this.events,
    this.lineup,
    this.odds,
    this.h2h,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final MatchDetailStatus status;
  final MatchDetailInfo? matchDetail;
  final dynamic events;
  final dynamic lineup;
  final MatchOddsInfo? odds;
  final dynamic h2h;
  final String? errorMessage;
  final bool isRefreshing;

  bool get hasData => matchDetail != null;

  MatchDetailState copyWith({
    MatchDetailStatus? status,
    MatchDetailInfo? matchDetail,
    dynamic events,
    dynamic lineup,
    MatchOddsInfo? odds,
    dynamic h2h,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return MatchDetailState(
      status: status ?? this.status,
      matchDetail: matchDetail ?? this.matchDetail,
      events: events ?? this.events,
      lineup: lineup ?? this.lineup,
      odds: odds ?? this.odds,
      h2h: h2h ?? this.h2h,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
