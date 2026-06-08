import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/auth/domain/models/auth_user.dart';
import 'package:fover/features/auth/providers/auth_provider.dart';

class _FakeAuthStorage implements AuthStorage {
  Map<String, String> values = {};

  @override
  Future<void> clearSession() async {
    values.clear();
  }

  @override
  Future<AuthSession?> readSession() async {
    final userJson = values['auth_user'];
    final token = values['auth_access_token'];

    if (userJson == null || token == null) {
      return null;
    }

    return AuthSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(userJson) as Map<String, dynamic>),
    ).copyWith(
      accessToken: token,
      refreshToken: values['auth_refresh_token'],
    );
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    values['auth_user'] = jsonEncode(session.toJson());
    values['auth_access_token'] = session.accessToken;
    if (session.refreshToken != null) {
      values['auth_refresh_token'] = session.refreshToken!;
    }
  }
}

void main() {
  test('restores an authenticated session from storage', () async {
    final storage = _FakeAuthStorage();
    final notifier = AuthNotifier(storage);

    await notifier.saveSession(
      const AuthUser(id: '1', email: 'test@example.com', name: 'Test User'),
      'access-token',
      refreshToken: 'refresh-token',
    );
    await notifier.initialize();

    expect(notifier.debugState.status, AuthStatus.authenticated);
    expect(notifier.debugState.user?.email, 'test@example.com');
    expect(notifier.debugState.accessToken, 'access-token');
  });

  test('signOut clears the session and resets state', () async {
    final storage = _FakeAuthStorage();
    final notifier = AuthNotifier(storage);

    await notifier.saveSession(
      const AuthUser(id: '1', email: 'test@example.com', name: 'Test User'),
      'access-token',
    );
    await notifier.signOut();

    expect(notifier.debugState.status, AuthStatus.unauthenticated);
    expect(storage.values, isEmpty);
  });
}
