class TeamInfo {
  const TeamInfo({
    required this.teamId,
    required this.name,
    required this.logoUrl,
    this.country,
    this.stadium,
    this.founded,
    this.createdAt,
    this.updatedAt,
  });

  final int teamId;
  final String name;
  final String logoUrl;
  final String? country;
  final String? stadium;
  final int? founded;
  final String? createdAt;
  final String? updatedAt;

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      teamId: json['team_id'] as int? ?? int.tryParse(json['team_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      logoUrl: json['logo'] as String? ?? '',
      country: json['country'] as String?,
      stadium: json['stadium'] as String?,
      founded: json['founded'] as int? ?? int.tryParse(json['founded']?.toString() ?? ''),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'name': name,
      'logo': logoUrl,
      'country': country,
      'stadium': stadium,
      'founded': founded,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
