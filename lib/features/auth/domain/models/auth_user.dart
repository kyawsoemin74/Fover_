class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.provider = 'local',
  });

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String provider;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      provider: json['provider']?.toString() ?? 'local',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'provider': provider,
    };
  }
}
