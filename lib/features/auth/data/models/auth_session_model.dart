import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final UserEntity user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    final accessToken = _firstString(payload, [
      'accessToken',
      'access_token',
      'token',
      'jwt',
    ]);
    final refreshToken = _firstString(payload, [
      'refreshToken',
      'refresh_token',
    ]);
    final expiresAt = _parseExpiry(payload);
    final userJson = _extractUser(payload);

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      user: _parseUser(userJson),
    );
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return json;
  }

  static Map<String, dynamic> _extractUser(Map<String, dynamic> payload) {
    final candidates = [
      payload['user'],
      payload['profile'],
      payload['account'],
    ];
    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
    }
    return payload;
  }

  static UserEntity _parseUser(Map<String, dynamic> json) {
    return UserEntity(
      id: (json['id'] ?? json['_id'] ?? json['uid'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['name'] ?? json['displayName'] ?? json['username'])
          ?.toString(),
      photoUrl: (json['photoUrl'] ?? json['avatarUrl'])?.toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
    );
  }

  static String _firstString(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static DateTime? _parseExpiry(Map<String, dynamic> payload) {
    final expiresAt = payload['expiresAt'] ?? payload['expires_at'];
    if (expiresAt is String) {
      return DateTime.tryParse(expiresAt);
    }
    final expiresIn = payload['expiresIn'] ?? payload['expires_in'];
    if (expiresIn is int) {
      return DateTime.now().add(Duration(seconds: expiresIn));
    }
    if (expiresIn is String) {
      final parsed = int.tryParse(expiresIn);
      if (parsed != null) {
        return DateTime.now().add(Duration(seconds: parsed));
      }
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
