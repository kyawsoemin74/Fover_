import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';
import 'package:fover/features/matches/providers/match_detail_state.dart';
import 'package:fover/features/matches/providers/match_events_provider.dart';
import 'package:fover/features/matches/providers/match_h2h_provider.dart';
import 'package:fover/features/matches/providers/match_lineup_provider.dart';
import 'package:fover/features/matches/providers/match_odds_provider.dart';
import 'package:fover/features/matches/providers/match_stats_provider.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_details_section.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_h2h_section.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_lineup_section.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_odds_section.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_standings_section.dart';
import 'package:fover/features/matches/presentation/widgets/match_detail_header.dart';
import 'package:fover/features/matches/presentation/widgets/match_detail_loading.dart';
import 'package:fover/features/matches/presentation/widgets/match_detail_tab_bar.dart';

class MatchDetailPage extends ConsumerStatefulWidget {
  const MatchDetailPage({
    super.key,
    required this.matchId,
    this.homeTeamId = 0,
    this.awayTeamId = 0,
  });

  final int matchId;
  final int homeTeamId;
  final int awayTeamId;

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

enum MatchDetailTab { details, lineups, odds, standings, knockout, h2h }

extension MatchDetailTabData on MatchDetailTab {
  String get title {
    switch (this) {
      case MatchDetailTab.details:
        return 'Details';
      case MatchDetailTab.lineups:
        return 'Lineups';
      case MatchDetailTab.odds:
        return 'Odds';
      case MatchDetailTab.standings:
        return 'Standings';
      case MatchDetailTab.knockout:
        return 'Knockout';
      case MatchDetailTab.h2h:
        return 'H2H';
    }
  }
}

List<MatchDetailTab> buildMatchDetailTabs(MatchDetailInfo detail) {
  final tabs = <MatchDetailTab>[MatchDetailTab.details];

  if (detail.hasLineups) {
    tabs.add(MatchDetailTab.lineups);
  }

  if (detail.hasOdds) {
    tabs.add(MatchDetailTab.odds);
  }

  if (detail.isKnockout && detail.hasBracket) {
    tabs.add(MatchDetailTab.knockout);
  } else if (detail.hasStandings) {
    tabs.add(MatchDetailTab.standings);
  }

  if (detail.hasH2H) {
    tabs.add(MatchDetailTab.h2h);
  }

  return tabs;
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  var _selectedTab = MatchDetailTab.details;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitialTabData);
  }

  void _loadInitialTabData() {
    if (widget.matchId <= 0) return;
    ref.read(matchEventsProvider(widget.matchId).notifier).loadEvents();
    ref.read(matchStatsProvider(widget.matchId).notifier).loadStats();
  }

  void _onTabSelected(MatchDetailTab tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
    _loadTabData(tab);
  }

  void _loadTabData(MatchDetailTab tab) {
    if (widget.matchId <= 0) return;

    switch (tab) {
      case MatchDetailTab.details:
        ref.read(matchEventsProvider(widget.matchId).notifier).loadEvents();
        ref.read(matchStatsProvider(widget.matchId).notifier).loadStats();
        break;
      case MatchDetailTab.odds:
        ref.read(matchOddsProvider(widget.matchId).notifier).loadOdds();
        break;
      case MatchDetailTab.lineups:
        ref.read(matchLineupProvider(widget.matchId).notifier).loadLineup();
        break;
      case MatchDetailTab.standings:
      case MatchDetailTab.knockout:
        break;
      case MatchDetailTab.h2h:
        ref
            .read(
              matchH2HProvider(
                MatchH2HRequest(
                  matchId: widget.matchId,
                  homeTeamId: widget.homeTeamId,
                  awayTeamId: widget.awayTeamId,
                ),
              ).notifier,
            )
            .loadH2H();
        break;
    }
  }

  Widget _buildBody(MatchDetailState summaryState) {
    if (summaryState.status == MatchDetailStatus.loading ||
        summaryState.status == MatchDetailStatus.initial) {
      return const MatchDetailLoadingView();
    }

    if (summaryState.status == MatchDetailStatus.error) {
      return _buildErrorState(summaryState.errorMessage);
    }

    if (summaryState.matchDetail == null) {
      return _buildErrorState('Match summary is unavailable.');
    }

    return _buildMatchCenter(summaryState.matchDetail!);
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.redAccent.withAlpha(230),
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage ?? 'Unable to load match data. Please try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(matchDetailProvider(widget.matchId).notifier)
                    .loadMatch(widget.matchId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCenter(MatchDetailInfo detail) {
    final tabs = buildMatchDetailTabs(detail);
    final selectedTab = tabs.contains(_selectedTab)
        ? _selectedTab
        : MatchDetailTab.details;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverToBoxAdapter(child: MatchDetailHeader(detail: detail)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: MatchDetailTabBar(
              selectedTab: selectedTab,
              tabs: tabs,
              onTabSelected: _onTabSelected,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: _buildSelectedSection(detail, selectedTab),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildSelectedSection(
    MatchDetailInfo detail,
    MatchDetailTab selectedTab,
  ) {
    switch (selectedTab) {
      case MatchDetailTab.details:
        return MatchDetailDetailsSection(
          matchId: widget.matchId,
          homeTeamId: widget.homeTeamId,
          awayTeamId: widget.awayTeamId,
        );
      case MatchDetailTab.odds:
        return MatchDetailOddsSection(matchId: widget.matchId);
      case MatchDetailTab.lineups:
        return MatchDetailLineupSection(matchId: widget.matchId);
      case MatchDetailTab.standings:
      case MatchDetailTab.knockout:
        return MatchDetailStandingsSection(detail: detail);
      case MatchDetailTab.h2h:
        return MatchDetailH2HSection(
          matchId: widget.matchId,
          homeTeamId: widget.homeTeamId,
          awayTeamId: widget.awayTeamId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId <= 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 24),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
          title: const Text('Match Detail'),
        ),
        body: const Center(child: Text('Invalid match selected.')),
      );
    }

    final summaryState = ref.watch(matchDetailProvider(widget.matchId));

    return Scaffold(
      backgroundColor: const Color(0xFF090B13),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 24),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: const SizedBox.shrink(),
        actions: [
          // TODO: Match Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            color: Colors.white70,
            onPressed: () {},
            tooltip: 'Match Notifications',
          ),
          // TODO: Favorite Match
          IconButton(
            icon: const Icon(Icons.star_outline, size: 20),
            color: Colors.white70,
            onPressed: () {},
            tooltip: 'Favorite Match',
          ),
          // TODO: More Actions Menu
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: Colors.white70,
            onPressed: () {},
            tooltip: 'More Actions Menu',
          ),
        ],
        backgroundColor: const Color(0xFF090B13),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      body: _buildBody(summaryState),
    );
  }
}
