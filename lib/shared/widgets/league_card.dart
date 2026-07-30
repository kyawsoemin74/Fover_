import 'package:flutter/material.dart';
import 'package:fover/core/utils/country_flag_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/home/domain/models/match_status_formatter.dart';
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
    this.leagueLogoUrl,
  });

  final String countryCode;
  final String leagueName;
  final int matchCount;
  final bool expanded;
  final VoidCallback onToggle;
  final List<MatchInfo> matches;
  final ValueChanged<MatchInfo>? onMatchTap;
  final String? countryFlagUrl;
  final String? leagueLogoUrl;

  String get _leagueLabel {
    if (countryCode.isNotEmpty) {
      return '$countryCode - $leagueName';
    }
    return leagueName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liveMatches = matches.where((match) => MatchStatusFormatter.isLive(match.status)).length;
    final totalMatches = matchCount > 0 ? matchCount : matches.length;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: Builder(
                          builder: (context) {
                            final code = CountryFlagHelper.extractCountryCode(
                              countryFlagUrl,
                            );

                            if (code != null && code.isNotEmpty) {
                              return CountryFlagHelper.buildCountryFlag(
                                countryFlagUrl,
                                size: 26,
                              );
                            }

                            if (leagueLogoUrl != null &&
                                leagueLogoUrl!.isNotEmpty) {
                              return CachedNetworkImage(
                                imageUrl: leagueLogoUrl!,
                                fit: BoxFit.cover,
                                width: 26,
                                height: 26,
                                placeholder: (_, _) => Center(
                                  child: SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.emoji_events,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              );
                            }

                            return Icon(
                              Icons.emoji_events,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _leagueLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 0, maxWidth: 80),
                        child: liveMatches > 0
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$liveMatches',
                                      style: const TextStyle(
                                        color: Color(0xFF00C853),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$totalMatches',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              )
                            : Text(
                                '$totalMatches',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
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
                      elapsed: match.elapsed,
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
