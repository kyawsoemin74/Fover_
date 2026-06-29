import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/standings/providers/standing_provider.dart';

class MatchDetailStandingsSection extends ConsumerWidget {
  const MatchDetailStandingsSection({super.key, required this.detail});

  static const double _sectionSpacing = 16;
  static const double _rowSpacing = 4;
  static const double _rowHeight = 40;
  static const double _rowRadius = 12;
  static const double _logoSize = 20;
  static const double _positionWidth = 20;
  static const double _statWidth = 28;
  static const double _cardPadding = 12;

  final MatchDetailInfo detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = _resolveSeason(detail);
    final request = StandingRequest(
      leagueId: detail.leagueId,
      season: season,
    );

    final standingsAsync = ref.watch(standingsProvider(request));

    return ListView(
      children: [
        standingsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _buildErrorState(context, ref, error.toString(), request),
          data: (standings) => _buildStandingsTable(context, standings),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String message,
    StandingRequest request,
  ) {
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
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(standingsProvider(request)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsTable(BuildContext context, List<StandingInfo> standings) {
    if (standings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No standings available for this league.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final currentTeamRow = standings.firstWhereOrNull(
      (row) => row.teamId == detail.homeTeamId || row.teamId == detail.awayTeamId,
    );
    final detectedGroup = currentTeamRow?.groupName;
    final filteredStandings = detectedGroup == null
        ? standings
        : standings.where((row) => row.groupName == detectedGroup).toList();
    final visibleStandings = filteredStandings.isEmpty ? standings : filteredStandings;

    bool isCurrentMatchTeam(StandingInfo standing) {
      return standing.teamId == detail.homeTeamId || standing.teamId == detail.awayTeamId;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          detectedGroup ?? 'League Standings',
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
              ...visibleStandings.map((standing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: _rowSpacing),
                  child: _StandingRow(
                    standing: standing,
                    isHighlighted: isCurrentMatchTeam(standing),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  String _resolveSeason(MatchDetailInfo detail) {
    if (detail.season.trim().isNotEmpty) {
      return detail.season;
    }

    final parsed = detail.createdAt != null
        ? DateTime.tryParse(detail.createdAt!)
        : null;

    return (parsed?.year ?? DateTime.now().year).toString();
  }
}

extension _FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
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
      height: MatchDetailStandingsSection._rowHeight - 12,
      child: Row(
        children: [
          SizedBox(
            width: MatchDetailStandingsSection._positionWidth,
            child: Text('#', style: style),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Team', style: style),
          ),
          SizedBox(
            width: MatchDetailStandingsSection._statWidth,
            child: Text('P', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MatchDetailStandingsSection._statWidth + 4,
            child: Text('GD', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MatchDetailStandingsSection._statWidth + 6,
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
      height: MatchDetailStandingsSection._rowHeight,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(MatchDetailStandingsSection._rowRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: MatchDetailStandingsSection._positionWidth,
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
            borderRadius: BorderRadius.circular(
              MatchDetailStandingsSection._logoSize / 2,
            ),
            child: SizedBox(
              width: MatchDetailStandingsSection._logoSize,
              height: MatchDetailStandingsSection._logoSize,
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
            width: MatchDetailStandingsSection._statWidth,
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
            width: MatchDetailStandingsSection._statWidth + 4,
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
            width: MatchDetailStandingsSection._statWidth + 6,
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
