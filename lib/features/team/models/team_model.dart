class TeamModel {
  const TeamModel({
    required this.teamId,
    required this.name,
    this.country,
    this.logo,
    this.stadium,
    this.founded,
  });

  final int teamId;
  final String name;
  final String? country;
  final String? logo;
  final String? stadium;
  final int? founded;

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId:
          json['team_id'] as int? ??
          int.tryParse(json['team_id']?.toString() ?? '') ??
          0,
      name: json['name'] as String? ?? '',
      country: json['country'] as String?,
      logo: json['logo'] as String?,
      stadium: json['stadium'] as String?,
      founded:
          json['founded'] as int? ??
          int.tryParse(json['founded']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'name': name,
      'country': country,
      'logo': logo,
      'stadium': stadium,
      'founded': founded,
    };
  }
}
