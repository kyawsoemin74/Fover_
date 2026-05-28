import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';

class MatchDetailHeader extends StatelessWidget {
  const MatchDetailHeader({super.key, required this.detail});

  final MatchDetailInfo detail;

  bool get _isLive => detail.status.toLowerCase().contains('live');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.leagueName,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.countryName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
              _StatusChip(isLive: _isLive, status: detail.status),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TeamPanel(
                name: detail.homeTeam,
                logoUrl: detail.homeTeamLogo,
                alignment: Alignment.centerRight,
              ),
              _ScoreDisplay(
                homeScore: detail.homeScore,
                awayScore: detail.awayScore,
                isLive: _isLive,
                matchTime: detail.matchTime,
              ),
              _TeamPanel(
                name: detail.awayTeam,
                logoUrl: detail.awayTeamLogo,
                alignment: Alignment.centerLeft,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            detail.matchTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isLive, required this.status});

  final bool isLive;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isLive ? 'LIVE' : status.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.name,
    required this.logoUrl,
    required this.alignment,
  });

  final String name;
  final String logoUrl;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignment == Alignment.centerRight ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: alignment == Alignment.centerRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF13223F),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _TeamInitial(name: name),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white24),
                    ),
                  )
                : _TeamInitial(name: name),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 92,
          child: Text(
            name,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({
    required this.homeScore,
    required this.awayScore,
    required this.isLive,
    required this.matchTime,
  });

  final int homeScore;
  final int awayScore;
  final bool isLive;
  final String matchTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F32),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            '$homeScore - $awayScore',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isLive ? 'Match in progress' : 'Kickoff at $matchTime',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}

class _TeamInitial extends StatelessWidget {
  const _TeamInitial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((part) => part[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      color: const Color(0xFF111827),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

