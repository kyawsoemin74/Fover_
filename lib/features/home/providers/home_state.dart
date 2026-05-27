import 'package:fover/core/providers/navigation_provider.dart';
import 'package:fover/features/home/domain/models/league_model.dart';

enum HomeStatus { initial, loading, loaded, refreshing, empty, error }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.selectedTab = FoverDateTab.today,
    this.expandedLeagueIds = const {'premier-league'},
    this.showFollowing = true,
    this.leagues = const [],
    this.errorMessage,
    this.isRefreshing = false,
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = true,
    this.isFetchingMore = false,
  });

  final HomeStatus status;
  final FoverDateTab selectedTab;
  final Set<String> expandedLeagueIds;
  final bool showFollowing;
  final List<LeagueInfo> leagues;
  final String? errorMessage;
  final bool isRefreshing;
  final int page;
  final int pageSize;
  final bool hasMore;
  final bool isFetchingMore;

  bool get hasData => leagues.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    FoverDateTab? selectedTab,
    Set<String>? expandedLeagueIds,
    bool? showFollowing,
    List<LeagueInfo>? leagues,
    String? errorMessage,
    bool? isRefreshing,
    int? page,
    int? pageSize,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return HomeState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      expandedLeagueIds: expandedLeagueIds ?? this.expandedLeagueIds,
      showFollowing: showFollowing ?? this.showFollowing,
      leagues: leagues ?? this.leagues,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
