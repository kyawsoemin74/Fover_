import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/standings/domain/league_standing_rules.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/standings/providers/standing_provider.dart';

class MatchDetailStandingsSection extends ConsumerWidget {
  const MatchDetailStandingsSection({super.key, required this.detail});

  final MatchDetailInfo detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = _resolveSeason(detail);
    final request = StandingRequest(leagueId: detail.leagueId, season: season);
    final standingsAsync = ref.watch(standingsProvider(request));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'League Standings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(18),
          child: standingsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => _buildErrorState(context, ref, error.toString(), request),
            data: (standings) => _buildStandingsTable(context, standings),
          ),
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

    bool isCurrentMatchTeam(StandingInfo standing) {
      return standing.teamId == detail.homeTeamId || standing.teamId == detail.awayTeamId;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 640),
        child: DataTable(
          headingTextStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
          dataTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          columnSpacing: 12,
          horizontalMargin: 0,
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text('Pos')),
            DataColumn(label: Text('Team')),
            DataColumn(label: Text('P')),
            DataColumn(label: Text('W')),
            DataColumn(label: Text('D')),
            DataColumn(label: Text('L')),
            DataColumn(label: Text('+/-')),
            DataColumn(label: Text('GD')),
            DataColumn(label: Text('Pts')),
          ],
          rows: standings.map((standing) {
            final rule = LeagueStandingRules.resolve(detail.leagueId, standing.position);
            final isHighlighted = isCurrentMatchTeam(standing);

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (isHighlighted) {
                  return const Color(0xFF172554).withAlpha(180);
                }
                return null;
              }),
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rule != null)
                        Container(
                          width: 4,
                          height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: rule.color,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      Text('${standing.position}'),
                    ],
                  ),
                ),
                DataCell(_TeamCell(standing: standing, isHighlighted: isHighlighted)),
                DataCell(Text('${standing.played}')),
                DataCell(Text('${standing.won}')),
                DataCell(Text('${standing.drawn}')),
                DataCell(Text('${standing.lost}')),
                DataCell(Text('${standing.goalsFor}-${standing.goalsAgainst}')),
                DataCell(Text(_formatGoalDifference(standing.goalDifference))),
                DataCell(Text('${standing.points}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatGoalDifference(int value) {
    if (value > 0) {
      return '+$value';
    }
    return value.toString();
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

class _TeamCell extends StatelessWidget {
  const _TeamCell({required this.standing, required this.isHighlighted});

  final StandingInfo standing;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? Border.all(color: const Color(0xFF3B82F6).withAlpha(120)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 28,
            height: 28,
            child: CachedNetworkImage(
              imageUrl: standing.teamLogo ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 18, color: Colors.white54),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            standing.teamName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
      ),
    );
  }
}
