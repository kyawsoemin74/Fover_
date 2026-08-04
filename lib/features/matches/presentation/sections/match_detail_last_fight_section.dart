import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/providers/team_finished_matches_provider.dart';
import 'package:fover/features/team/providers/team_finished_matches_state.dart';

class MatchDetailLastFightSection extends ConsumerWidget {
  const MatchDetailLastFightSection({
    super.key,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int homeTeamId;
  final int awayTeamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(teamFinishedMatchesProvider(homeTeamId));
    final awayState = ref.watch(teamFinishedMatchesProvider(awayTeamId));
    final rowCount = [
      homeState.matches.length,
      awayState.matches.length,
    ].reduce((value, element) => value > element ? value : element);
    final effectiveRowCount = rowCount > 0 ? rowCount : 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Home Team',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Away Team',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(effectiveRowCount, (index) {
            final homeMatch = index < homeState.matches.length
                ? homeState.matches[index]
                : null;
            final awayMatch = index < awayState.matches.length
                ? awayState.matches[index]
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildComparisonCell(
                      context: context,
                      match: homeMatch,
                      state: homeState,
                      teamId: homeTeamId,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildComparisonCell(
                      context: context,
                      match: awayMatch,
                      state: awayState,
                      teamId: awayTeamId,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonCell({
    required BuildContext context,
    required TeamFinishedMatch? match,
    required TeamFinishedMatchesState state,
    required int teamId,
  }) {
    if (match != null) {
      return _buildMatchCard(context, match, teamId);
    }

    switch (state.status) {
      case TeamFinishedMatchesStatus.loading:
      case TeamFinishedMatchesStatus.initial:
        return _buildStatusCard(
          context,
          const SizedBox(
            height: 44,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
          ),
        );
      case TeamFinishedMatchesStatus.error:
        return _buildStatusCard(
          context,
          Text(
            state.errorMessage ?? 'Unable to load recent matches',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case TeamFinishedMatchesStatus.empty:
        return const SizedBox.shrink();
      case TeamFinishedMatchesStatus.loaded:
      case TeamFinishedMatchesStatus.refreshing:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMatchCard(
    BuildContext context,
    TeamFinishedMatch match,
    int teamId,
  ) {
    final opponentLabel = _opponentLabelForTeam(match, teamId);
    final opponentLogoUrl = _opponentLogoForTeam(match, teamId);
    final scoreLabel = '${match.homeScore ?? '-'} - ${match.awayScore ?? '-'}';
    final resultLabel = _shortResultLabelForTeam(match, teamId);
    final resultColor = _resultColor(resultLabel);
    final leagueName = (match.competitionName ?? '').trim();
    final rawKickOffTime = (match.kickOffTime ?? '').trim();
    final hasMetadata = leagueName.isNotEmpty && rawKickOffTime.isNotEmpty;
    final formattedDate = hasMetadata ? _formatMatchDate(rawKickOffTime) : null;
    final shouldShowMetadata = hasMetadata && formattedDate != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (match.matchId != null && match.matchId! > 0) {
          context.pushNamed(
            'matchDetail',
            pathParameters: {'matchId': match.matchId!.toString()},
            queryParameters: {
              'homeTeamId': match.homeTeamId.toString(),
              'awayTeamId': match.awayTeamId.toString(),
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF090B13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (opponentLogoUrl != null &&
                      opponentLogoUrl.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        opponentLogoUrl.trim(),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 24, height: 24),
                      ),
                    )
                  else
                    const SizedBox(width: 24, height: 24),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      opponentLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  scoreLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (shouldShowMetadata) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: Text(
                  leagueName,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: Text(
                  formattedDate,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF090B13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  String _opponentLabelForTeam(TeamFinishedMatch match, int currentTeamId) {
    if (match.homeTeamId == currentTeamId) {
      return match.awayTeamName?.trim().isNotEmpty == true
          ? match.awayTeamName!
          : 'Away';
    }
    if (match.awayTeamId == currentTeamId) {
      return match.homeTeamName?.trim().isNotEmpty == true
          ? match.homeTeamName!
          : 'Home';
    }
    return match.awayTeamName?.trim().isNotEmpty == true
        ? match.awayTeamName!
        : 'Opponent';
  }

  String? _opponentLogoForTeam(TeamFinishedMatch match, int currentTeamId) {
    if (match.homeTeamId == currentTeamId) {
      return match.awayTeamLogo?.trim().isNotEmpty == true
          ? match.awayTeamLogo
          : null;
    }
    if (match.awayTeamId == currentTeamId) {
      return match.homeTeamLogo?.trim().isNotEmpty == true
          ? match.homeTeamLogo
          : null;
    }
    return null;
  }

  String _shortResultLabelForTeam(TeamFinishedMatch match, int currentTeamId) {
    if (match.homeTeamId == currentTeamId) {
      if ((match.homeScore ?? 0) > (match.awayScore ?? 0)) return '🟢 W';
      if ((match.homeScore ?? 0) < (match.awayScore ?? 0)) return '🔴 L';
      return '⚪ D';
    }
    if (match.awayTeamId == currentTeamId) {
      if ((match.awayScore ?? 0) > (match.homeScore ?? 0)) return '🟢 W';
      if ((match.awayScore ?? 0) < (match.homeScore ?? 0)) return '🔴 L';
      return '⚪ D';
    }
    return '⚪ D';
  }

  String? _formatMatchDate(String rawKickOffTime) {
    if (rawKickOffTime.isEmpty) return null;

    try {
      final parsedDate = DateTime.parse(rawKickOffTime);
      return DateFormat('dd MMM yyyy').format(parsedDate.toLocal());
    } catch (_) {
      return null;
    }
  }

  Color _resultColor(String resultLabel) {
    switch (resultLabel) {
      case '🟢 W':
        return const Color(0xFF32D583);
      case '⚪ D':
        return Colors.white60;
      case '🔴 L':
        return const Color(0xFFFF5D5D);
      default:
        return Colors.white60;
    }
  }
}
