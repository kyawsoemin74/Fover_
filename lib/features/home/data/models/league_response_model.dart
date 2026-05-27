import 'package:fover/features/home/data/models/match_response_model.dart';
import 'package:fover/features/home/domain/models/league_model.dart';

class LeagueResponseModel {
  LeagueResponseModel({
    required this.id,
    required this.countryCode,
    required this.leagueName,
    required this.matches,
    this.countryFlagUrl,
  });

  final String id;
  final String countryCode;
  final String leagueName;
  final List<MatchResponseModel> matches;
  final String? countryFlagUrl;

  factory LeagueResponseModel.fromJson(Map<String, dynamic> json) {
    return LeagueResponseModel(
      id: json['id'] as String? ?? json['leagueId']?.toString() ?? '',
      countryCode: json['countryCode'] as String? ?? json['country_name'] as String? ?? '',
      countryFlagUrl: json['countryFlagUrl'] as String? ?? json['country_logo'] as String?,
      leagueName: json['leagueName'] as String? ?? json['league_name'] as String? ?? json['name'] as String? ?? '',
      matches: (json['matches'] as List<dynamic>?)
              ?.map((match) => MatchResponseModel.fromJson(Map<String, dynamic>.from(match as Map)))
              .toList() ??
          const [],
    );
  }

  LeagueInfo toDomain() {
    return LeagueInfo(
      id: id,
      countryCode: countryCode,
      leagueName: leagueName,
      countryFlagUrl: countryFlagUrl,
      matches: matches.map((match) => match.toDomain()).toList(),
    );
  }
}
