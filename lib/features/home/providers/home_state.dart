import 'package:fover/features/home/domain/models/league_model.dart';

enum HomeStatus { initial, loading, loaded, refreshing, empty, error }

class HomeState {
  HomeState({
    this.status = HomeStatus.loading,
    DateTime? selectedDate,
    this.expandedLeagueIds = const {'premier-league'},
    this.showFollowing = true,
    this.leagues = const [],
    this.errorMessage,
    this.isRefreshing = false,
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = true,
    this.isFetchingMore = false,
  }) : selectedDate = selectedDate ?? _todayDateOnly();

  static DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  final HomeStatus status;
  final DateTime selectedDate;
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
    DateTime? selectedDate,
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
      selectedDate: selectedDate ?? this.selectedDate,
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
