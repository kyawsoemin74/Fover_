import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fover/features/home/domain/models/match_status_formatter.dart';
import 'package:fover/features/matches/domain/models/goal_summary.dart';
import 'package:fover/features/matches/domain/models/goal_summary_result.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';

class MatchDetailHeader extends StatelessWidget {
  const MatchDetailHeader({
    super.key,
    required this.detail,
    this.goalSummary,
    this.onHomeTeamTap,
    this.onAwayTeamTap,
  });

  final MatchDetailInfo detail;
  final GoalSummaryResult? goalSummary;
  final VoidCallback? onHomeTeamTap;
  final VoidCallback? onAwayTeamTap;

  bool get _isUpcoming => detail.status.toUpperCase() == 'NS';

  @override
  Widget build(BuildContext context) {
    final status = detail.status.trim();
    final normalizedStatus = status.toUpperCase();
    final isUpcoming = _isUpcoming || normalizedStatus.contains('UPCOMING');
    final isHalfTime = normalizedStatus == 'HT';
    final isLive = !isUpcoming && !isHalfTime && MatchStatusFormatter.isLive(status);
    final completedStatusLabel = MatchStatusFormatter.display(status, elapsed: detail.elapsed);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TeamPanel(
                    name: detail.homeTeam,
                    logoUrl: detail.homeTeamLogo,
                    onTap: onHomeTeamTap,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ScoreDisplay(
                homeScore: detail.homeScore,
                awayScore: detail.awayScore,
                isUpcoming: isUpcoming,
                isHalfTime: isHalfTime,
                isLive: isLive,
                completedStatusLabel: completedStatusLabel,
                matchTime: detail.matchTime,
                elapsed: detail.elapsed,
                status: status,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _TeamPanel(
                    name: detail.awayTeam,
                    logoUrl: detail.awayTeamLogo,
                    onTap: onAwayTeamTap,
                  ),
                ),
              ),
            ],
          ),
          if (goalSummary != null && (goalSummary!.homeGoalScorers.isNotEmpty || goalSummary!.awayGoalScorers.isNotEmpty)) ...[
            const SizedBox(height: 10),
            _GoalSummaryList(
              goalSummary: goalSummary!,
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.name,
    required this.logoUrl,
    this.onTap,
  });

  final String name;
  final String logoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Material(
            color: const Color(0xFF050B1A),
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 54,
                height: 54,
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
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 88),
          child: Text(
            name,
            textAlign: TextAlign.center,
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
    required this.isHalfTime,
    required this.isLive,
    required this.completedStatusLabel,
    required this.matchTime,
    required this.elapsed,
    required this.status,
  });

  final int homeScore;
  final int awayScore;
  final bool isUpcoming;
  final bool isHalfTime;
  final bool isLive;
  final String completedStatusLabel;
  final String matchTime;
  final int elapsed;
  final String status;

  @override
  Widget build(BuildContext context) {
    if (isUpcoming) {
      return Text(
        matchTime,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$homeScore - $awayScore',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 30,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          completedStatusLabel.isNotEmpty
              ? completedStatusLabel
              : isHalfTime
                  ? 'HT'
                  : isLive
                      ? (elapsed > 0 ? '$elapsed\'' : matchTime)
                      : matchTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: MatchStatusFormatter.getStatusColor(status, context: context),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _GoalSummaryList extends StatelessWidget {
  const _GoalSummaryList({required this.goalSummary});

  final GoalSummaryResult goalSummary;

  @override
  Widget build(BuildContext context) {
    final homeScorers = _GoalSummaryPresenter.groupScorers(goalSummary.homeGoalScorers);
    final awayScorers = _GoalSummaryPresenter.groupScorers(goalSummary.awayGoalScorers);

    if (homeScorers.isEmpty && awayScorers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: homeScorers.map((entry) {
                  return _ScorerText(
                    text: entry.displayText,
                    textAlign: TextAlign.end,
                  );
                }).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.sports_soccer,
                size: 16,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: awayScorers.map((entry) {
                  return _ScorerText(
                    text: entry.displayText,
                    textAlign: TextAlign.start,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalSummaryPresenter {
  static List<_GroupedGoalSummaryEntry> groupScorers(List<GoalSummary> scorers) {
    if (scorers.isEmpty) {
      return const <_GroupedGoalSummaryEntry>[];
    }

    final grouped = <String, List<GoalSummary>>{};

    for (final scorer in scorers) {
      final playerName = scorer.playerName.trim();
      if (playerName.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(playerName, () => <GoalSummary>[]).add(scorer);
    }

    return grouped.entries.map((entry) {
      final sortedEvents = entry.value
          .asMap()
          .entries
          .toList()
        ..sort((left, right) {
          final leftScorer = left.value;
          final rightScorer = right.value;
          final minuteComparison = leftScorer.minute.compareTo(rightScorer.minute);
          if (minuteComparison != 0) {
            return minuteComparison;
          }

          final extraMinuteComparison = leftScorer.extraMinute.compareTo(rightScorer.extraMinute);
          if (extraMinuteComparison != 0) {
            return extraMinuteComparison;
          }

          return left.key.compareTo(right.key);
        });

      final combinedLabels = sortedEvents.map((event) {
        final scorer = event.value;
        final minuteLabel = scorer.extraMinute > 0
            ? '${scorer.minute}+${scorer.extraMinute}'
            : '${scorer.minute}';
        final suffix = scorer.isPenalty ? ' (P)' : scorer.isOwnGoal ? ' (OG)' : '';
        return '$minuteLabel\'$suffix';
      }).toList();

      return _GroupedGoalSummaryEntry(
        displayText: '${entry.key} ${combinedLabels.join(', ')}',
      );
    }).toList();
  }
}

class _GroupedGoalSummaryEntry {
  const _GroupedGoalSummaryEntry({required this.displayText});

  final String displayText;
}

class _ScorerText extends StatelessWidget {
  const _ScorerText({required this.text, required this.textAlign});

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        textAlign: textAlign,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
