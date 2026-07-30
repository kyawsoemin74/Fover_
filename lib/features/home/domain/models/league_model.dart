import 'package:fover/features/home/domain/models/match_model.dart';

class LeagueInfo {
  const LeagueInfo({
    required this.id,
    required this.countryCode,
    required this.leagueName,
    required this.matches,
    this.countryFlagUrl,
    this.leagueLogoUrl,
  });

  final String id;
  final String countryCode;
  final String leagueName;
  final List<MatchInfo> matches;

  int get liveMatches => matches.where((match) {
    final normalizedStatus = match.status.toUpperCase().trim();
    if (normalizedStatus.isEmpty || _isFinishedStatus(normalizedStatus)) {
      return false;
    }

    return normalizedStatus.startsWith('1H') ||
        normalizedStatus.startsWith('HT') ||
        normalizedStatus.startsWith('2H') ||
        normalizedStatus.startsWith('ET') ||
        normalizedStatus.startsWith('BT') ||
        normalizedStatus == 'P';
  }).length;
  int get totalMatches => matches.length;
  final String? countryFlagUrl;
  final String? leagueLogoUrl;

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    final leagueLogoUrl =
        json['leagueLogoUrl'] as String? ?? json['league_logo'] as String?;
    final countryFlagUrl = json['countryFlagUrl'] as String?;

    return LeagueInfo(
      id: json['id'] as String? ?? json['leagueId'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      countryFlagUrl: countryFlagUrl,
      leagueLogoUrl: leagueLogoUrl,
      leagueName:
          json['leagueName'] as String? ?? json['name'] as String? ?? '',
      matches:
          (json['matches'] as List<dynamic>?)
              ?.map(
                (item) =>
                    MatchInfo.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'countryFlagUrl': countryFlagUrl,
      'leagueLogoUrl': leagueLogoUrl,
      'leagueName': leagueName,
      'matches': matches.map((match) => match.toJson()).toList(),
    };
  }

  bool _isFinishedStatus(String status) {
    const finishedStatuses = {
      'PEN',
      'FT',
      'AET',
      'FT_PEN',
      'CANC',
      'PST',
      'ABD',
      'SUSP',
      'INT',
      'AWD',
      'WO',
    };
    return finishedStatuses.contains(status.toUpperCase().trim());
  }
}
