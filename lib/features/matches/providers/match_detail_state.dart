import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';

enum MatchDetailStatus { initial, loading, loaded, refreshing, error }

class MatchDetailState {
  const MatchDetailState({
    this.status = MatchDetailStatus.initial,
    this.matchDetail,
    this.errorMessage,
    this.isRefreshing = false,
    this.selectedTab = MatchDetailTab.details,
  });

  final MatchDetailStatus status;
  final MatchDetailInfo? matchDetail;
  final String? errorMessage;
  final bool isRefreshing;
  final MatchDetailTab selectedTab;

  bool get hasData => matchDetail != null;

  MatchDetailState copyWith({
    MatchDetailStatus? status,
    MatchDetailInfo? matchDetail,
    String? errorMessage,
    bool? isRefreshing,
    MatchDetailTab? selectedTab,
  }) {
    return MatchDetailState(
      status: status ?? this.status,
      matchDetail: matchDetail ?? this.matchDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
