import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:fover/features/matches/presentation/sections/match_detail_stats_section.dart';
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

enum MatchDetailTab { details, odds, stats, lineups, standings, h2h }

extension MatchDetailTabData on MatchDetailTab {
  String get title {
    switch (this) {
      case MatchDetailTab.details:
        return 'Details';
      case MatchDetailTab.odds:
        return 'Odds';
      case MatchDetailTab.stats:
        return 'Stats';
      case MatchDetailTab.lineups:
        return 'Lineups';
      case MatchDetailTab.standings:
        return 'Standings';
      case MatchDetailTab.h2h:
        return 'H2H';
    }
  }
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
        break;
      case MatchDetailTab.odds:
        ref.read(matchOddsProvider(widget.matchId).notifier).loadOdds();
        break;
      case MatchDetailTab.stats:
        ref.read(matchStatsProvider(widget.matchId).notifier).loadStats();
        break;
      case MatchDetailTab.lineups:
        ref.read(matchLineupProvider(widget.matchId).notifier).loadLineup();
        break;
      case MatchDetailTab.standings:
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
              selectedTab: _selectedTab,
              onTabSelected: _onTabSelected,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverToBoxAdapter(child: _buildSelectedSection(detail)),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildSelectedSection(MatchDetailInfo detail) {
    switch (_selectedTab) {
      case MatchDetailTab.details:
        return MatchDetailDetailsSection(
          matchId: widget.matchId,
          homeTeamId: widget.homeTeamId,
          awayTeamId: widget.awayTeamId,
        );
      case MatchDetailTab.odds:
        return MatchDetailOddsSection(matchId: widget.matchId);
      case MatchDetailTab.stats:
        return MatchDetailStatsSection(matchId: widget.matchId);
      case MatchDetailTab.lineups:
        return MatchDetailLineupSection(matchId: widget.matchId);
      case MatchDetailTab.standings:
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
        appBar: AppBar(title: const Text('Match Center')),
        body: const Center(child: Text('Invalid match selected.')),
      );
    }

    final summaryState = ref.watch(matchDetailProvider(widget.matchId));

    return Scaffold(
      backgroundColor: const Color(0xFF090B13),
      appBar: AppBar(
        title: const Text('Match Center'),
        backgroundColor: const Color(0xFF090B13),
        elevation: 0,
        centerTitle: true,
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
