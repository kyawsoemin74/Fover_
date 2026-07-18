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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _registerTabLoaders();
    Future.microtask(_loadInitialTabData);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _registerTabLoaders() {
    if (widget.matchId <= 0) return;

    final notifier = ref.read(matchDetailProvider(widget.matchId).notifier);

    notifier.registerTabLoader(MatchDetailTab.lineups, ({bool forceRefresh = false}) async {
      await ref.read(matchLineupProvider(widget.matchId).notifier).loadLineup(forceRefresh: forceRefresh);
    });

    notifier.registerTabLoader(MatchDetailTab.odds, ({bool forceRefresh = false}) async {
      await ref.read(matchOddsProvider(widget.matchId).notifier).loadOdds(forceRefresh: forceRefresh);
    });

    notifier.registerTabLoader(MatchDetailTab.h2h, ({bool forceRefresh = false}) async {
      await ref.read(
        matchH2HProvider(
          MatchH2HRequest(
            matchId: widget.matchId,
            homeTeamId: widget.homeTeamId,
            awayTeamId: widget.awayTeamId,
          ),
        ).notifier,
      ).loadH2H(forceRefresh: forceRefresh);
    });
  }

  void _loadInitialTabData() {
    if (widget.matchId <= 0) return;
  }

  void _onTabSelected(MatchDetailTab tab) {
    final state = ref.read(matchDetailProvider(widget.matchId));
    if (state.selectedTab == tab) return;
    ref.read(matchDetailProvider(widget.matchId).notifier).setSelectedTab(tab);
    _syncPageToTab(tab);
  }

  void _onPageChanged(int index) {
    final tabs = _availableTabsForDetail(ref.read(matchDetailProvider(widget.matchId)).matchDetail);
    if (index < 0 || index >= tabs.length) return;
    ref.read(matchDetailProvider(widget.matchId).notifier).setSelectedTab(tabs[index]);
  }

  void _syncPageToTab(MatchDetailTab tab) {
    final detail = ref.read(matchDetailProvider(widget.matchId)).matchDetail;
    final tabs = _availableTabsForDetail(detail);
    final index = tabs.indexOf(tab);
    if (index < 0 || !_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  List<MatchDetailTab> _availableTabsForDetail(MatchDetailInfo? detail) {
    if (detail == null) {
      return const [MatchDetailTab.details];
    }
    return buildMatchDetailTabs(detail);
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
    final selectedTab = ref.watch(matchDetailProvider(widget.matchId)).selectedTab;
    final resolvedTab = tabs.contains(selectedTab) ? selectedTab : MatchDetailTab.details;
    final goalSummary = ref.watch(matchEventsProvider(widget.matchId)).goalSummary;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final targetIndex = tabs.indexOf(resolvedTab);
      if (targetIndex < 0) return;
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != targetIndex) {
        _pageController.jumpToPage(targetIndex);
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: MatchDetailHeader(
            detail: detail,
            goalSummary: goalSummary,
            onHomeTeamTap: detail.homeTeamId > 0
                ? () => context.push('/team/${detail.homeTeamId}')
                : null,
            onAwayTeamTap: detail.awayTeamId > 0
                ? () => context.push('/team/${detail.awayTeamId}')
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: MatchDetailTabBar(
            selectedTab: resolvedTab,
            tabs: tabs,
            onTabSelected: _onTabSelected,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: PageView.builder(
              controller: _pageController,
              itemCount: tabs.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildSelectedSection(detail, tabs[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
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
