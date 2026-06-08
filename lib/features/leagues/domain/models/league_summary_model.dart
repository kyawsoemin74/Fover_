class LeagueSummaryModel {
  const LeagueSummaryModel({
    required this.leagueId,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.logo,
    required this.season,
    required this.isFeatured,
    required this.displayOrder,
  });

  final int leagueId;
  final String name;
  final String country;
  final String countryCode;
  final String logo;
  final String season;
  final bool isFeatured;
  final int displayOrder;

  factory LeagueSummaryModel.fromJson(Map<String, dynamic> json) {
    return LeagueSummaryModel(
      leagueId:
          json['league_id'] as int? ??
          int.tryParse(json['league_id']?.toString() ?? '') ??
          0,
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      countryCode:
          (json['countryCode'] as String?) ??
          (json['country_code'] as String?) ??
          '',
      logo: json['logo'] as String? ?? '',
      season: json['season'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder:
          json['display_order'] as int? ??
          int.tryParse(json['display_order']?.toString() ?? '') ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'league_id': leagueId,
      'name': name,
      'country': country,
      'countryCode': countryCode,
      'country_code': countryCode,
      'logo': logo,
      'season': season,
      'is_featured': isFeatured,
      'display_order': displayOrder,
    };
  }
}
