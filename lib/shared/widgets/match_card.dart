import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.kickOffTime,
    required this.status,
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
    final normalizedStatus = status.toUpperCase();
    final isNS = normalizedStatus == 'NS' || normalizedStatus == 'UPCOMING' || normalizedStatus == 'SCHEDULED';
    final showScore = !isNS && score.isNotEmpty;
    final scoreParts = _parseScore(score);
    final statusLabel = _formatStatus(status);
    final teamBLine = isNS ? teamB : '$statusLabel $teamB';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kickOffTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!isNS) ...[
                      const SizedBox(height: 2),
                      Text(
                        statusLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
              if (showScore) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scoreParts[0],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scoreParts[1],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    final normalized = status.toUpperCase();
    if (normalized == 'LIVE' || normalized == 'HT' || normalized == 'FT') {
      return normalized;
    }
    return status;
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
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              width: 20,
              height: 20,
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
