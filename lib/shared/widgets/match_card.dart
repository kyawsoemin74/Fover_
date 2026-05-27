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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = status == 'LIVE';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _TeamRow(
                  teamName: teamA,
                  redCards: redCardsA,
                  yellowCards: yellowCardsA,
                  logoUrl: teamALogoUrl,
                ),
                const SizedBox(height: 14),
                _TeamRow(
                  teamName: teamB,
                  redCards: redCardsB,
                  yellowCards: yellowCardsB,
                  logoUrl: teamBLogoUrl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _StatusBadge(status: status, isLive: isLive),
              const SizedBox(height: 8),
              Text(
                kickOffTime,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.teamName,
    required this.redCards,
    required this.yellowCards,
    this.logoUrl,
  });

  final String teamName;
  final int redCards;
  final int yellowCards;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.22),
          child: logoUrl != null && logoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: logoUrl!,
                  fit: BoxFit.cover,
                  width: 28,
                  height: 28,
                  errorWidget: (context, url, error) => Text(
                    teamName.split(' ').map((part) => part.characters.first).take(2).join(),
                    style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                )
              : Text(
                  teamName.split(' ').map((part) => part.characters.first).take(2).join(),
                  style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            teamName,
            style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (yellowCards > 0) ...[
          _CardCounter(
            color: const Color(0xFFFFD300),
            label: yellowCards.toString(),
          ),
          const SizedBox(width: 6),
        ],
        if (redCards > 0)
          _CardCounter(
            color: const Color(0xFFEF4444),
            label: redCards.toString(),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isLive,
  });

  final String status;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFFEF4444) : theme.colorScheme.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
              color: isLive ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CardCounter extends StatelessWidget {
  const _CardCounter({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
