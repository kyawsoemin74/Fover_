import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';

class MatchDetailHeader extends StatelessWidget {
  const MatchDetailHeader({super.key, required this.detail});

  final MatchDetailInfo detail;

  bool get _isLive => detail.status.toLowerCase().contains('live');
  bool get _isUpcoming => detail.status.toUpperCase() == 'NS';
  bool get _shouldShowBadge =>
      _isLive ||
      ['HT', 'FT', 'ET', 'PEN'].contains(detail.status.toUpperCase());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.countryName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_shouldShowBadge)
                _StatusChip(isLive: _isLive, status: detail.status),
              if (!_shouldShowBadge && _isUpcoming)
                Text(
                  detail.matchTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
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
                isUpcoming: _isUpcoming,
                matchTime: detail.matchTime,
              ),
              _TeamPanel(
                name: detail.awayTeam,
                logoUrl: detail.awayTeamLogo,
                alignment: Alignment.centerLeft,
              ),
            ],
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

  String get _displayStatus {
    final upper = status.toUpperCase();
    if (upper == 'NS') return '';
    if (isLive) return 'LIVE';
    return upper;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayStatus.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFFEF4444) : const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _displayStatus,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
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
    final textAlign = alignment == Alignment.centerRight
        ? TextAlign.right
        : TextAlign.left;
    return Column(
      crossAxisAlignment: alignment == Alignment.centerRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Container(
            width: 76,
            height: 76,
            color: const Color(0xFF0F172A),
            child: logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _TeamInitial(name: name),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white24,
                      ),
                    ),
                  )
                : _TeamInitial(name: name),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 94,
          child: Text(
            name,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
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
    required this.isUpcoming,
    required this.matchTime,
  });

  final int homeScore;
  final int awayScore;
  final bool isUpcoming;
  final String matchTime;

  @override
  Widget build(BuildContext context) {
    if (isUpcoming) {
      return Text(
        matchTime,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      );
    }

    return Text(
      '$homeScore - $awayScore',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _TeamInitial extends StatelessWidget {
  const _TeamInitial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((part) => part[0])
              .take(2)
              .join()
              .toUpperCase()
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
