import 'package:fover/features/matches/domain/models/match_detail_model.dart';

enum MatchDetailStatus { initial, loading, loaded, refreshing, error }

class MatchDetailState {
  const MatchDetailState({
    this.status = MatchDetailStatus.initial,
    this.matchDetail,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final MatchDetailStatus status;
  final MatchDetailInfo? matchDetail;
  final String? errorMessage;
  final bool isRefreshing;

  bool get hasData => matchDetail != null;

  MatchDetailState copyWith({
    MatchDetailStatus? status,
    MatchDetailInfo? matchDetail,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return MatchDetailState(
      status: status ?? this.status,
      matchDetail: matchDetail ?? this.matchDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
