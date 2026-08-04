import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/ads/widgets/ad_slot.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/presentation/team_facts_tab.dart';
import 'package:fover/features/team/presentation/team_matches_tab.dart';
import 'package:fover/features/team/presentation/team_placeholder_tab.dart';
import 'package:fover/features/team/presentation/team_profile_header_layout.dart';
import 'package:fover/features/team/presentation/team_profile_tabs.dart';
import 'package:fover/features/team/presentation/team_squad_tab.dart';
import 'package:fover/features/team/presentation/team_standings_tab.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/providers/team_state.dart';

class TeamProfilePage extends ConsumerWidget {
  const TeamProfilePage({super.key, required this.teamId});

  final int teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (teamId <= 0) {
      return Scaffold(
        backgroundColor: const Color(0xFF090B13),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 24),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
          title: const Text('Team Profile'),
          backgroundColor: const Color(0xFF090B13),
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Invalid team selected.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final state = ref.watch(teamProvider(teamId));

    return Scaffold(
      backgroundColor: const Color(0xFF090B13),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, TeamState state) {
    if (state.status == TeamStatus.loading || state.status == TeamStatus.initial) {
      return const _TeamProfileLoading();
    }

    if (state.status == TeamStatus.error) {
      return _TeamProfileError(
        message: state.errorMessage,
        onRetry: () => ref.read(teamProvider(teamId).notifier).reload(teamId),
      );
    }

    final team = state.team;
    if (team == null) {
      return _TeamProfileError(
        onRetry: () => ref.read(teamProvider(teamId).notifier).reload(teamId),
      );
    }

    return _TeamProfileContent(team: team);
  }
}

class _TeamProfileContent extends StatelessWidget {
  const _TeamProfileContent({required this.team});

  static const tabs = [
    'Team Facts',
    'Matches',
    'Standings',
    'Squad',
    'Top Players',
  ];

  final TeamModel team;

  @override
  Widget build(BuildContext context) {
    final headerTitle = team.name.isEmpty ? 'Team' : team.name;

    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildTeamHeaderSliver(context, headerTitle, innerBoxIsScrolled),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedTabBarDelegate(
                child: Container(
                  color: const Color(0xFF090B13),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TeamProfileTabs(tabs: tabs),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            _KeepAliveTabBody(
              keyName: 'team-facts',
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: BannerAdSlot(placement: BannerPlacement.teamDetail),
                  ),
                  Expanded(child: TeamFactsTab(team: team)),
                ],
              ),
            ),
            _KeepAliveTabBody(
              keyName: 'matches',
              child: TeamMatchesTab(teamId: team.teamId),
            ),
            _KeepAliveTabBody(
              keyName: 'standings',
              child: TeamStandingsTab(teamId: team.teamId),
            ),
            _KeepAliveTabBody(
              keyName: 'squad',
              child: TeamSquadTab(teamId: team.teamId),
            ),
            _KeepAliveTabBody(
              keyName: 'top-players',
              child: const TeamPlaceholderTab(title: 'Top Players'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeaderSliver(
    BuildContext context,
    String title,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      expandedHeight: 172,
      pinned: true,
      floating: false,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: const Color(0xFF090B13),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left_rounded, size: 24),
        color: Colors.white,
        onPressed: () => context.pop(),
        tooltip: 'Back',
      ),
      title: innerBoxIsScrolled
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 74, 16, 10),
          color: const Color(0xFF090B13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFF050B1A),
                  child: (team.logo ?? '').trim().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: team.logo!.trim(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white24,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.shield_outlined,
                            color: Colors.white70,
                            size: 40,
                          ),
                        )
                      : const Icon(
                          Icons.shield_outlined,
                          color: Colors.white70,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({required this.child});

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => TeamProfileHeaderLayout.height;

  @override
  double get minExtent => TeamProfileHeaderLayout.height;

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _KeepAliveTabBody extends StatefulWidget {
  const _KeepAliveTabBody({required this.child, required this.keyName});

  final Widget child;
  final String keyName;

  @override
  State<_KeepAliveTabBody> createState() => _KeepAliveTabBodyState();
}

class _KeepAliveTabBodyState extends State<_KeepAliveTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (context) {
          return CustomScrollView(
            key: PageStorageKey<String>(widget.keyName),
            controller: PrimaryScrollController.of(context),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 24),
                sliver: SliverToBoxAdapter(child: widget.child),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamProfileError extends StatelessWidget {
  const _TeamProfileError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 48),
          const SizedBox(height: 12),
          Text(
            'Failed to load team profile',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TeamProfileLoading extends StatelessWidget {
  const _TeamProfileLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF121826),
      highlightColor: const Color(0xFF1B2335),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1220),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white12,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 180,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                child: Container(
                  width: 92,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1220),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
