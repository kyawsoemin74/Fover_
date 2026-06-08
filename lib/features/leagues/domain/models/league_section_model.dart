import 'package:fover/features/leagues/domain/models/league_summary_model.dart';

class LeagueSectionModel {
  const LeagueSectionModel({
    required this.type,
    required this.title,
    required this.leagues,
    this.country,
    this.countryCode,
  });

  final String type;
  final String title;
  final String? country;
  final String? countryCode;
  final List<LeagueSummaryModel> leagues;

  factory LeagueSectionModel.fromJson(Map<String, dynamic> json) {
    final parsedLeagues =
        (json['leagues'] as List<dynamic>?)
            ?.map(
              (item) => LeagueSummaryModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

    final leagues = parsedLeagues ?? const <LeagueSummaryModel>[];
    final derivedCountryCode =
        leagues.isNotEmpty ? leagues.first.countryCode : null;

    return LeagueSectionModel(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      country: json['country'] as String?,
      countryCode:
          (json['countryCode'] as String?) ??
          (json['country_code'] as String?) ??
          derivedCountryCode,
      leagues: leagues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'country': country,
      'countryCode': countryCode,
      'country_code': countryCode,
      'leagues': leagues.map((league) => league.toJson()).toList(),
    };
  }
}
