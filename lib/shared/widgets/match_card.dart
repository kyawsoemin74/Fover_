import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fover/features/home/domain/models/match_status_formatter.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.kickOffTime,
    required this.status,
    this.elapsed = 0,
    this.redCardsA = 0,
    this.redCardsB = 0,
    this.yellowCardsA = 0,
    this.yellowCardsB = 0,
    this.teamALogoUrl,
    this.teamBLogoUrl,
    this.onTap,
  });

  final String teamA;
  final String teamB;
  final String score;
  final String kickOffTime;
  final String status;
  final int elapsed;
  final int redCardsA;
  final int redCardsB;
  final int yellowCardsA;
  final int yellowCardsB;
  final String? teamALogoUrl;
  final String? teamBLogoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedStatus = status.toUpperCase().trim();
    final isNS = normalizedStatus == 'NS' || normalizedStatus == 'UPCOMING' || normalizedStatus == 'SCHEDULED';
    final showScore = !isNS && score.isNotEmpty;
    final scoreParts = _parseScore(score);
    final statusLine = _buildStatusLine(status, elapsed);
    final isLongStatusLabel = const <String>{'CANC', 'PST', 'ABD', 'SUSP', 'INT'}.contains(normalizedStatus);
    final statusColor = MatchStatusFormatter.getStatusColor(status, context: context);
    final statusFontSize = isLongStatusLabel ? 11.5 : 13.0;
    final teamBLine = teamB;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kickOffTime,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (statusLine.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        statusLine,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: statusFontSize,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TeamLine(
                      teamName: teamA,
                      logoUrl: teamALogoUrl,
                    ),
                    const SizedBox(height: 2),
                    _TeamLine(
                      teamName: teamBLine,
                      logoUrl: teamBLogoUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      showScore ? scoreParts[0] : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showScore ? scoreParts[1] : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 38,
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildStatusLine(String status, int elapsed) {
    return MatchStatusFormatter.display(status, elapsed: elapsed);
  }


  List<String> _parseScore(String value) {
    final parts = value.split(RegExp(r'\s*[-:]\s*'));
    if (parts.length == 2) {
      return parts;
    }
    return [value, ''];
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.teamName,
    this.logoUrl,
  });

  final String teamName;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (logoUrl != null && logoUrl!.isNotEmpty) ...[
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              width: 22,
              height: 22,
              errorWidget: (context, url, error) => Center(
                child: Text(
                  teamName.split(' ').map((part) => part.characters.first).take(2).join(),
                  style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            teamName,
            style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
