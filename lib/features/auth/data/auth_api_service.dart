import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/auth/domain/models/auth_user.dart';

class GoogleAuthResponse {
  const GoogleAuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final AuthUser user;

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthResponse(
      accessToken:
          json['access_token']?.toString() ??
          json['accessToken']?.toString() ??
          '',
      refreshToken:
          json['refresh_token']?.toString() ?? json['refreshToken']?.toString(),
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
    );
  }
}

class AuthApiService {
  AuthApiService({Dio? dio}) : _dio = dio ?? DioClient.shared.dio;

  final Dio _dio;

  Future<GoogleAuthResponse> signInWithGoogle(String idToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/google',
      data: {
        'token_in': idToken,
      },
    );

    final payload = response.data;
    if (payload == null) {
      throw const FormatException(
        'Google sign-in response was empty.',
      );
    }

    return GoogleAuthResponse.fromJson(
      Map<String, dynamic>.from(payload),
    );
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});
