import 'package:flutter/material.dart';
import 'package:fover/core/utils/country_flag_helper.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/shared/widgets/match_card.dart';

class LeagueCard extends StatelessWidget {
  const LeagueCard({
    super.key,
    required this.countryCode,
    required this.leagueName,
    required this.matchCount,
    required this.expanded,
    required this.onToggle,
    required this.matches,
    this.onMatchTap,
    this.countryFlagUrl,
  });

  final String countryCode;
  final String leagueName;
  final int matchCount;
  final bool expanded;
  final VoidCallback onToggle;
  final List<MatchInfo> matches;
  final ValueChanged<MatchInfo>? onMatchTap;
  final String? countryFlagUrl;


  String get _leagueLabel {
    if (countryCode.isNotEmpty) {
      return '$countryCode - $leagueName';
    }
    return leagueName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Center(
                            child: CountryFlagHelper.buildCountryFlag(countryFlagUrl, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _leagueLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$matchCount',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                child: Column(
                  children: matches.map((match) {
                    return MatchCard(
                      teamA: match.teamA,
                      teamB: match.teamB,
                      score: match.score,
                      kickOffTime: match.kickOffTime,
                      status: match.status,
                      redCardsA: match.redCardsA,
                      redCardsB: match.redCardsB,
                      yellowCardsA: match.yellowCardsA,
                      yellowCardsB: match.yellowCardsB,
                      teamALogoUrl: match.teamALogoUrl,
                      teamBLogoUrl: match.teamBLogoUrl,
                      onTap: match.matchId > 0
                          ? () {
                              onMatchTap?.call(match);
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
