import 'package:equatable/equatable.dart';

/// Modelo de usuário vindo do backend
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    this.email,
    this.name,
    this.username,
    this.photoUrl,
    this.crewId,
    this.createdAt,
    this.updatedAt,
    this.extras = const {},
  });

  final String id;
  final String? email;
  final String? name;
  final String? username;
  final String? photoUrl;
  final String? crewId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> extras;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ??
            json['_id'] ??
            json['uid'] ??
            json['userId'] ??
            '')
        .toString();
    final createdAt = _parseDate(json['createdAt'] ?? json['created_at']);
    final updatedAt = _parseDate(json['updatedAt'] ?? json['updated_at']);
    final extras = Map<String, dynamic>.from(json)
      ..removeWhere(
        (key, _) => [
          'id',
          '_id',
          'uid',
          'userId',
          'email',
          'name',
          'displayName',
          'username',
          'handle',
          'photoUrl',
          'avatarUrl',
          'crewId',
          'crew_id',
          'createdAt',
          'created_at',
          'updatedAt',
          'updated_at',
        ].contains(key),
      );

    return UserModel(
      id: id,
      email: json['email'] as String?,
      name: (json['name'] ?? json['displayName']) as String?,
      username: (json['username'] ?? json['handle']) as String?,
      photoUrl: (json['photoUrl'] ?? json['avatarUrl']) as String?,
      crewId: (json['crewId'] ?? json['crew_id']) as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      extras: extras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (crewId != null) 'crewId': crewId,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      ...extras,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        username,
        photoUrl,
        crewId,
        createdAt,
        updatedAt,
        extras,
      ];
}
