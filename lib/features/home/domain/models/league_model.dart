import 'package:fover/features/home/domain/models/match_model.dart';

class LeagueInfo {
  const LeagueInfo({
    required this.id,
    required this.countryCode,
    required this.leagueName,
    required this.matches,
    this.countryFlagUrl,
  });

  final String id;
  final String countryCode;
  final String leagueName;
  final List<MatchInfo> matches;
  final String? countryFlagUrl;

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      id: json['id'] as String? ?? json['leagueId'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      countryFlagUrl: json['countryFlagUrl'] as String?,
      leagueName: json['leagueName'] as String? ?? json['name'] as String? ?? '',
      matches: (json['matches'] as List<dynamic>?)
              ?.map((item) => MatchInfo.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'countryFlagUrl': countryFlagUrl,
      'leagueName': leagueName,
      'matches': matches.map((match) => match.toJson()).toList(),
    };
  }
}
