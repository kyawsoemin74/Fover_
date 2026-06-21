import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/presentation/team_facts_tab.dart';
import 'package:fover/features/team/presentation/team_placeholder_tab.dart';
import 'package:fover/features/team/presentation/team_profile_tabs.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(context, ref, state),
      ),
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
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TeamProfileHeader(team: team),
          const SizedBox(height: 16),
          const TeamProfileTabs(tabs: tabs),
          const SizedBox(height: 14),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: TeamFactsTab(team: team),
                ),
                const SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: TeamPlaceholderTab(title: 'Matches'),
                ),
                const SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: TeamPlaceholderTab(title: 'Standings'),
                ),
                const SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: TeamPlaceholderTab(title: 'Squad'),
                ),
                const SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: TeamPlaceholderTab(title: 'Top Players'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamProfileHeader extends StatelessWidget {
  const _TeamProfileHeader({required this.team});

  final TeamModel team;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Container(
              width: 92,
              height: 92,
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
                        size: 44,
                      ),
                    )
                  : const Icon(
                      Icons.shield_outlined,
                      color: Colors.white70,
                      size: 44,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            team.name.isEmpty ? 'Team' : team.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
