import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/providers/team_state.dart';

class TeamStandingsTab extends ConsumerStatefulWidget {
  const TeamStandingsTab({super.key, required this.teamId});

  final int teamId;

  @override
  ConsumerState<TeamStandingsTab> createState() => _TeamStandingsTabState();
}

class _TeamStandingsTabState extends ConsumerState<TeamStandingsTab> {
  static const double _sectionSpacing = 16;
  static const double _rowSpacing = 4;
  static const double _rowHeight = 40;
  static const double _rowRadius = 12;
  static const double _logoSize = 20;
  static const double _positionWidth = 20;
  static const double _statWidth = 28;
  static const double _cardPadding = 12;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teamProvider(widget.teamId).notifier).loadStandings(widget.teamId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamProvider(widget.teamId));
    final standings = state.standings;

    if (state.standingsStatus == TeamStandingsStatus.loading || state.standingsStatus == TeamStandingsStatus.initial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.standingsStatus == TeamStandingsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load standings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.standingsErrorMessage ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.standingsStatus == TeamStandingsStatus.empty || standings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No standings available for this team.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final groupLabel = standings.firstWhere((row) => row.groupName != null, orElse: () => standings.first).groupName ?? 'League Standings';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          groupLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: _sectionSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: _cardPadding,
            vertical: _cardPadding,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _StandingsHeaderRow(),
              const SizedBox(height: _rowSpacing),
              ...standings.map((standing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: _rowSpacing),
                  child: _StandingRow(
                    standing: standing,
                    isHighlighted: standing.teamId == widget.teamId,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandingsHeaderRow extends StatelessWidget {
  const _StandingsHeaderRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white60,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );

    return SizedBox(
      height: _TeamStandingsTabState._rowHeight - 12,
      child: Row(
        children: [
          SizedBox(
            width: _TeamStandingsTabState._positionWidth,
            child: Text('#', style: style),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Team', style: style),
          ),
          SizedBox(
            width: _TeamStandingsTabState._statWidth,
            child: Text('P', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _TeamStandingsTabState._statWidth + 4,
            child: Text('GD', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _TeamStandingsTabState._statWidth + 6,
            child: Text('PTS', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, required this.isHighlighted});

  final StandingInfo standing;
  final bool isHighlighted;

  String get _goalDifferenceLabel {
    if (standing.goalDifference > 0) {
      return '+${standing.goalDifference}';
    }
    return '${standing.goalDifference}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: _TeamStandingsTabState._rowHeight,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(_TeamStandingsTabState._rowRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: _TeamStandingsTabState._positionWidth,
            child: Text(
              '${standing.position}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(_TeamStandingsTabState._logoSize / 2),
            child: SizedBox(
              width: _TeamStandingsTabState._logoSize,
              height: _TeamStandingsTabState._logoSize,
              child: CachedNetworkImage(
                imageUrl: standing.teamLogo ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.sports_soccer,
                  size: 16,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              standing.teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: _TeamStandingsTabState._statWidth,
            child: Text(
              '${standing.played}',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _TeamStandingsTabState._statWidth + 4,
            child: Text(
              _goalDifferenceLabel,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _TeamStandingsTabState._statWidth + 6,
            child: Text(
              '${standing.points}',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
