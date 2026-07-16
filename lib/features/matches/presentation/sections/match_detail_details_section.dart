import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_event_display_mapper.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_stats_section.dart';
import 'package:fover/features/matches/presentation/widgets/match_prediction_card.dart';
import 'package:fover/features/matches/providers/match_events_provider.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';
import 'package:fover/features/matches/providers/match_stats_provider.dart';

class MatchDetailDetailsSection extends ConsumerStatefulWidget {
  const MatchDetailDetailsSection({
    super.key,
    required this.matchId,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int matchId;
  final int homeTeamId;
  final int awayTeamId;

  @override
  ConsumerState<MatchDetailDetailsSection> createState() =>
      _MatchDetailDetailsSectionState();
}

class _MatchDetailDetailsSectionState
    extends ConsumerState<MatchDetailDetailsSection> {
  var _requestedEvents = false;
  var _requestedStats = false;

  void _maybeRequestSecondaryLoads(MatchDetailInfo? matchInfo) {
    if (matchInfo == null) return;

    if (matchInfo.hasEvents && !_requestedEvents) {
      _requestedEvents = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(matchEventsProvider(widget.matchId).notifier).loadEvents();
      });
    }

    if (matchInfo.hasStats && !_requestedStats) {
      _requestedStats = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(matchStatsProvider(widget.matchId).notifier).loadStats();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchDetailProvider(widget.matchId));
    final matchInfo = matchState.matchDetail;
    _maybeRequestSecondaryLoads(matchInfo);

    final showEvents = matchInfo?.hasEvents == true;
    final showStatistics = matchInfo?.hasStats == true;

    final state = showEvents
        ? ref.watch(matchEventsProvider(widget.matchId))
        : const MatchEventsState();

    final events = state.events;
    final showTimeline = state.status == MatchEventsStatus.loaded && events.isNotEmpty;
    final showEventsLoading =
      state.status == MatchEventsStatus.loading || state.status == MatchEventsStatus.initial;
    final showEventsEmpty = state.status == MatchEventsStatus.empty;
    final showEventsError = state.status == MatchEventsStatus.error;

    // Sort events by minute and extraMinute
    final sorted = List<MatchEventInfo>.from(events)
      ..sort((a, b) {
        final aTotal = a.minute * 100 + a.extraMinute;
        final bTotal = b.minute * 100 + b.extraMinute;
        return aTotal.compareTo(bTotal);
      });

    // Determine whether to show HT/FT based on match status/elapsed
    final showHT =
        matchInfo != null &&
        (matchInfo.elapsed > 45 ||
            matchInfo.status.toLowerCase().contains('ht'));
    final showFT =
        matchInfo != null &&
        (matchInfo.status.toLowerCase().contains('ft') ||
            matchInfo.status.toLowerCase().contains('full'));

    // Compute running score and build display items with optional period dividers
    final items = <_DisplayItem>[];
    var homeScore = 0;
    var awayScore = 0;

    // find last first-half event index
    var lastFirstHalfIndex = -1;
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i].minute <= 45) lastFirstHalfIndex = i;
    }

    for (var i = 0; i < sorted.length; i++) {
      // if we need HT divider before first second-half event and there were no first-half events
      if (showHT &&
          lastFirstHalfIndex == -1 &&
          sorted[i].minute > 45 &&
          items.isEmpty) {
        items.add(_DisplayItem.period('HT', 0, 0));
      }

      final e = sorted[i];

      String? scoreSnapshot;
      final isGoalEvent =
          e.type == MatchEventType.goal ||
          e.type == MatchEventType.ownGoal ||
          e.type == MatchEventType.penalty;
      if (isGoalEvent) {
        if (e.teamId == widget.homeTeamId) {
          homeScore++;
        } else if (e.teamId == widget.awayTeamId) {
          awayScore++;
        }
        scoreSnapshot = '$homeScore-$awayScore';
      }

      // Add event with score snapshot for goals
      items.add(_DisplayItem.event(e, score: scoreSnapshot));

      // insert HT divider after last first-half event
      if (showHT && i == lastFirstHalfIndex && lastFirstHalfIndex != -1) {
        items.add(_DisplayItem.period('HT', homeScore, awayScore));
      }
    }

    // FT divider
    if (showFT) {
      // prefer final score from matchInfo (showFT implies matchInfo != null)
      final fHome = matchInfo.homeScore;
      final fAway = matchInfo.awayScore;
      items.add(_DisplayItem.period('FT', fHome, fAway));
    }

    final venueText = [
      matchInfo?.venueName,
      matchInfo?.venueCity,
    ].where((entry) => entry != null && entry.trim().isNotEmpty).join(', ');
    final locationText = matchInfo?.venueCity?.trim() ?? '';

    return ListView(
      children: [
        if (showStatistics) ...[
          MatchDetailStatsSection(matchId: widget.matchId),
          const SizedBox(height: 16),
        ],
        if (showEventsLoading) ...[
          const SizedBox.shrink(),
        ] else if (showEventsError) ...[
          _SectionStatusCard(
            icon: Icons.error_outline,
            title: 'Events unavailable',
            message: state.errorMessage ?? 'Unable to load match events.',
            actionLabel: 'Retry',
            onAction: () {
              ref
                  .read(matchEventsProvider(widget.matchId).notifier)
                  .loadEvents(forceRefresh: true);
            },
          ),
          const SizedBox(height: 16),
        ] else if (showEventsEmpty) ...[
          const _SectionStatusCard(
            icon: Icons.event_note_outlined,
            title: 'No events yet',
            message: 'No match events are available for this game yet.',
          ),
          const SizedBox(height: 16),
        ] else if (showTimeline) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1220),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MatchDetailSectionHeader(title: 'Events'),
                const SizedBox(height: 12),
                ...items.map((it) {
                  if (it.isPeriod) {
                    return _ScoreDivider(
                      label: it.label!,
                      home: it.home!,
                      away: it.away!,
                    );
                  }
                  final ev = it.event!;
                  return _FotMobRow(
                    event: ev,
                    homeTeamId: widget.homeTeamId,
                    awayTeamId: widget.awayTeamId,
                    score: it.score,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (matchInfo != null) ...[
          MatchPredictionCard(
            homeTeamName: matchInfo.homeTeam,
            awayTeamName: matchInfo.awayTeam,
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1220),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MatchDetailSectionHeader(title: 'Match Information'),
              const SizedBox(height: 16),
              MatchDetailInfoRow(
                icon: '📍',
                title: 'Venue',
                subtitle: venueText,
              ),
              const SizedBox(height: 12),
              MatchDetailInfoRow(
                icon: '🌍',
                title: 'Location',
                subtitle: locationText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MatchDetailSectionHeader extends StatelessWidget {
  const MatchDetailSectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF11131D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MatchDetailInfoRow extends StatelessWidget {
  const MatchDetailInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionStatusCard extends StatelessWidget {
  const _SectionStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FotMobRow extends StatelessWidget {
  const _FotMobRow({
    required this.event,
    required this.homeTeamId,
    required this.awayTeamId,
    this.score,
  });

  final MatchEventInfo event;
  final int homeTeamId;
  final int awayTeamId;
  final String? score;

  String _formatMinute(MatchEventInfo e) {
    final base = e.minute.toString();
    return e.extraMinute > 0 ? '$base+${e.extraMinute}\'' : '$base\'';
  }

  String? _scoreLabel(MatchEventInfo e) {
    final raw = e.raw;
    if (raw['score'] != null) {
      return raw['score'].toString();
    }
    final home =
        raw['home_score'] ??
        raw['score_home'] ??
        raw['team_home_score'] ??
        raw['home'] ??
        raw['homeScore'];
    final away =
        raw['away_score'] ??
        raw['score_away'] ??
        raw['team_away_score'] ??
        raw['away'] ??
        raw['awayScore'];
    if (home != null && away != null) {
      return '${home.toString()}-${away.toString()}';
    }
    return null;
  }

  List<String> _parseSubstitution(MatchEventInfo e) {
    final raw = e.raw;
    dynamic inPlayer =
        raw['sub_on'] ??
        raw['player_in'] ??
        raw['substitute_in'] ??
        raw['playerIn'] ??
        raw['in_player'] ??
        raw['sub_in'] ??
        raw['on'] ??
        raw['in'];
    dynamic outPlayer =
        raw['sub_off'] ??
        raw['player_out'] ??
        raw['substitute_out'] ??
        raw['playerOut'] ??
        raw['out_player'] ??
        raw['sub_out'] ??
        raw['off'] ??
        raw['out'];

    String extractName(dynamic value) {
      if (value == null) return '';
      if (value is Map) {
        return (value['name'] ??
                value['player_name'] ??
                value['full_name'] ??
                value['fullName'] ??
                '')
            .toString();
      }
      return value.toString();
    }

    if (inPlayer == null || outPlayer == null) {
      for (final entry in raw.entries) {
        if (entry.value is Map) {
          final nested = entry.value as Map<String, dynamic>;
          inPlayer ??=
              nested['sub_on'] ??
              nested['player_in'] ??
              nested['substitute_in'] ??
              nested['playerIn'] ??
              nested['in_player'] ??
              nested['sub_in'] ??
              nested['on'] ??
              nested['in'];
          outPlayer ??=
              nested['sub_off'] ??
              nested['player_out'] ??
              nested['substitute_out'] ??
              nested['playerOut'] ??
              nested['out_player'] ??
              nested['sub_out'] ??
              nested['off'] ??
              nested['out'];
        }
      }
    }

    if (inPlayer != null || outPlayer != null) {
      return [extractName(inPlayer), extractName(outPlayer)];
    }

    final detail = e.detail;
    final arrowMatch = RegExp(r"(.+?)\s*[->→]\s*(.+)").firstMatch(detail);
    if (arrowMatch != null) {
      return [arrowMatch.group(1)!.trim(), arrowMatch.group(2)!.trim()];
    }

    final parts = detail.split(RegExp(r"[,;/]"));
    if (parts.length >= 2) {
      return [parts[0].trim(), parts[1].trim()];
    }

    return ['', ''];
  }

  Widget _buildSubstitutionLine(
    BuildContext context,
    String icon,
    String label,
    TextAlign align,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Text(
        '$icon $label',
        textAlign: align,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: icon == '🟢' ? Colors.greenAccent : Colors.redAccent,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context, bool isHome) {
    final displayType = MatchEventDisplayMapper.fromEvent(event);
    final rawScore = _scoreLabel(event);
    final scoreLabel = score ?? rawScore;
    final playerName = event.playerName.isNotEmpty
        ? event.playerName
        : event.detail;
    final textAlign = isHome ? TextAlign.left : TextAlign.right;
    final crossAxis = isHome
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;

    switch (displayType) {
      case MatchEventDisplayType.substitution:
        final inName = event.assistName?.trim();
        final outName = event.playerName.isNotEmpty
            ? event.playerName.trim()
            : null;
        final fallback = _parseSubstitution(event);
        final inLabel = inName?.isNotEmpty == true
            ? inName
            : (fallback[0].isNotEmpty ? fallback[0] : null);
        final outLabel = outName?.isNotEmpty == true
            ? outName
            : (fallback[1].isNotEmpty ? fallback[1] : null);

        if (inLabel == null && outLabel == null) {
          final fallbackText = event.detail.isNotEmpty
              ? event.detail
              : (event.playerName.isNotEmpty ? event.playerName : 'Substitution');
          return Text(
            fallbackText,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          );
        }

        return Column(
          crossAxisAlignment: crossAxis,
          children: [
            if (inLabel != null)
              _buildSubstitutionLine(context, '🟢', inLabel, textAlign),
            if (outLabel != null)
              _buildSubstitutionLine(context, '🔴', outLabel, textAlign),
          ],
        );
      case MatchEventDisplayType.goal:
      case MatchEventDisplayType.penaltyGoal:
      case MatchEventDisplayType.ownGoal:
      case MatchEventDisplayType.penalty:
        final primaryText = '${displayType == MatchEventDisplayType.penalty ? '⚽' : '⚽'} $playerName${scoreLabel != null ? ' ($scoreLabel)' : ''}';
        return Column(
          crossAxisAlignment: crossAxis,
          children: [
            Text(
              primaryText,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            if (event.assistName != null)
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Text(
                  'Assist by ${event.assistName}',
                  textAlign: textAlign,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        );
      case MatchEventDisplayType.yellowCard:
        return _buildSimpleText(context, textAlign, '🟨 $playerName', crossAxis);
      case MatchEventDisplayType.redCard:
        return _buildSimpleText(context, textAlign, '🟥 $playerName', crossAxis);
      case MatchEventDisplayType.secondYellow:
        return _buildSimpleText(context, textAlign, '🟨🟥 $playerName', crossAxis);
      case MatchEventDisplayType.goalCancelled:
        return _buildVarCancelledText(context, textAlign, playerName, crossAxis);
      case MatchEventDisplayType.goalConfirmed:
        return _buildVarConfirmedText(context, textAlign, playerName, crossAxis);
      case MatchEventDisplayType.varCheck:
        return _buildVarCheckText(context, textAlign, playerName, crossAxis);
      case MatchEventDisplayType.redCardConfirmed:
        return _buildRedCardConfirmedText(context, textAlign, playerName, crossAxis);
      case MatchEventDisplayType.redCardCancelled:
        return _buildRedCardCancelledText(context, textAlign, playerName, crossAxis);
      case MatchEventDisplayType.missedPenalty:
        return _buildSimpleText(context, textAlign, '❌⚽ $playerName', crossAxis);
      case MatchEventDisplayType.injury:
        return _buildSimpleText(context, textAlign, '🩹 $playerName', crossAxis);
      case MatchEventDisplayType.kickoff:
      case MatchEventDisplayType.halfTime:
      case MatchEventDisplayType.fullTime:
      case MatchEventDisplayType.extraTime:
      case MatchEventDisplayType.penaltyShootout:
      case MatchEventDisplayType.unknown:
        return _buildSimpleText(context, textAlign, playerName, crossAxis);
    }
  }

  Widget _buildSimpleText(
    BuildContext context,
    TextAlign textAlign,
    String text,
    CrossAxisAlignment crossAxis,
  ) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildVarCheckText(
    BuildContext context,
    TextAlign textAlign,
    String playerName,
    CrossAxisAlignment crossAxis,
  ) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '🖥️ VAR Check',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (playerName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              playerName,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVarConfirmedText(
    BuildContext context,
    TextAlign textAlign,
    String playerName,
    CrossAxisAlignment crossAxis,
  ) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '✅🖥️ Goal Confirmed',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (playerName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              playerName,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVarCancelledText(
    BuildContext context,
    TextAlign textAlign,
    String playerName,
    CrossAxisAlignment crossAxis,
  ) {
    final reason = _deriveVarReason(event.detail);

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '❌🖥️ Goal Cancelled',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (playerName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              playerName,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
        if (reason.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              reason,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRedCardConfirmedText(
    BuildContext context,
    TextAlign textAlign,
    String playerName,
    CrossAxisAlignment crossAxis,
  ) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '✅🟥 Red Card Confirmed',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (playerName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              playerName,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRedCardCancelledText(
    BuildContext context,
    TextAlign textAlign,
    String playerName,
    CrossAxisAlignment crossAxis,
  ) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '❌🟥 Red Card Cancelled',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (playerName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              playerName,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }

  String _deriveVarReason(String detail) {
    final normalized = detail.trim();
    if (normalized.isEmpty) return '';
    final marker = normalized.contains('-')
        ? normalized.split('-').last.trim()
        : normalized;
    return marker.isNotEmpty ? marker : '';
  }

  @override
  Widget build(BuildContext context) {
    final isHome = event.teamId == homeTeamId;
    final minute = _formatMinute(event);
    final minuteWidget = SizedBox(
      width: 48,
      child: Text(
        minute,
        textAlign: isHome ? TextAlign.left : TextAlign.right,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isHome
            ? [
                minuteWidget,
                const SizedBox(width: 8),
                Expanded(child: _buildEventContent(context, isHome)),
              ]
            : [
                Expanded(child: _buildEventContent(context, isHome)),
                const SizedBox(width: 8),
                minuteWidget,
              ],
      ),
    );
  }
}

class _ScoreDivider extends StatelessWidget {
  const _ScoreDivider({
    required this.label,
    required this.home,
    required this.away,
  });
  final String label;
  final int home;
  final int away;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          const SizedBox(width: 8),
          Text(
            '$label $home-$away',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
        ],
      ),
    );
  }
}

class _DisplayItem {
  const _DisplayItem._({
    this.event,
    this.label,
    this.home,
    this.away,
    this.score,
  });

  factory _DisplayItem.event(MatchEventInfo e, {String? score}) =>
      _DisplayItem._(event: e, score: score);
  factory _DisplayItem.period(String label, int home, int away) =>
      _DisplayItem._(label: label, home: home, away: away);

  final MatchEventInfo? event;
  final String? label;
  final int? home;
  final int? away;
  final String? score;

  bool get isPeriod => label != null;
}

