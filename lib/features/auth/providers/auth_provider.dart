import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fover/features/auth/domain/models/auth_user.dart';

const String _authUserKey = 'fover_auth_user';
const String _authAccessTokenKey = 'fover_auth_access_token';
const String _authRefreshTokenKey = 'fover_auth_refresh_token';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String? refreshToken;

  AuthSession copyWith({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract class AuthStorage {
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> readSession();
  Future<void> clearSession();
}

class SecureAuthStorage implements AuthStorage {
  SecureAuthStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _authUserKey, value: jsonEncode(session.toJson())),
      _storage.write(key: _authAccessTokenKey, value: session.accessToken),
      if (session.refreshToken != null)
        _storage.write(key: _authRefreshTokenKey, value: session.refreshToken!)
      else
        _storage.delete(key: _authRefreshTokenKey),
    ]);
  }

  @override
  Future<AuthSession?> readSession() async {
    final userJson = await _storage.read(key: _authUserKey);
    final accessToken = await _storage.read(key: _authAccessTokenKey);

    if (userJson == null || accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      final session = AuthSession.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return session.copyWith(
        accessToken: accessToken,
        refreshToken: await _storage.read(key: _authRefreshTokenKey),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _authUserKey),
      _storage.delete(key: _authAccessTokenKey),
      _storage.delete(key: _authRefreshTokenKey),
    ]);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storage) : super(const AuthState(status: AuthStatus.unknown));

  final AuthStorage _storage;

  @override
  AuthState get debugState => state;

  Future<void> initialize() async {
    final session = await _storage.readSession();

    if (session == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = AuthState(
      status: AuthStatus.authenticated,
      user: session.user,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  Future<void> saveSession(
    AuthUser user,
    String accessToken, {
    String? refreshToken,
  }) async {
    final session = AuthSession(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await _storage.saveSession(session);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> signOut() async {
    await _storage.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authStorageProvider = Provider<AuthStorage>((ref) {
  return SecureAuthStorage();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(authStorageProvider);
  final notifier = AuthNotifier(storage);
  notifier.initialize();
  return notifier;
});
