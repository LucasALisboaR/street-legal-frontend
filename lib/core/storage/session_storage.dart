import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gearhead_br/features/users/data/models/user_model.dart';

/// Gerencia sessão local do usuário usando armazenamento seguro
class SessionStorage {
  SessionStorage(this._storage);

  static const _userKey = 'session_user';
  static const _userIdKey = 'session_user_id';
  static const _currentCarIdKey = 'session_current_car_id';

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

  Future<void> clear() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _currentCarIdKey);
  }
}
