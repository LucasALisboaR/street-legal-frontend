import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gearhead_br/features/users/data/models/user_model.dart';

/// Gerencia sessão local do usuário usando armazenamento seguro
class SessionStorage {
  SessionStorage(this._storage);

  static const _userKey = 'session_user';
  static const _userIdKey = 'session_user_id';
  static const _currentCarIdKey = 'session_current_car_id';
  static const _accessTokenKey = 'session_access_token';
  static const _refreshTokenKey = 'session_refresh_token';
  static const _accessTokenExpiresAtKey = 'session_access_token_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
    await saveUserId(user.id);
  }

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  Future<void> saveCurrentCarId(String carId) async {
    await _storage.write(key: _currentCarIdKey, value: carId);
  }

  Future<String?> getCurrentCarId() async {
    return _storage.read(key: _currentCarIdKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(
        key: _accessTokenExpiresAtKey,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getAccessTokenExpiresAt() async {
    final raw = await _storage.read(key: _accessTokenExpiresAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiresAtKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _currentCarIdKey);
    await clearTokens();
  }
}
