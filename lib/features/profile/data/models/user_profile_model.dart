import 'package:equatable/equatable.dart';

/// Modelo completo de perfil do usuário retornado pela API
class UserProfileModel extends Equatable {
  const UserProfileModel({
    required this.id,
    this.name,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.isOnline = false,
    this.joinedAt,
    this.stats,
    this.crew,
    this.garage = const [],
    this.achievements = const [],
  });

  final String id;
  final String? name;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final bool isOnline;
  final DateTime? joinedAt;
  final UserProfileStats? stats;
  final UserProfileCrew? crew;
  final List<UserProfileVehicle> garage;
  final List<UserProfileAchievement> achievements;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      joinedAt: _parseDate(json['joinedAt']),
      stats: json['stats'] != null
          ? UserProfileStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      crew: json['crew'] != null
          ? UserProfileCrew.fromJson(json['crew'] as Map<String, dynamic>)
          : null,
      garage: json['garage'] != null
          ? (json['garage'] as List)
              .map((e) => UserProfileVehicle.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      achievements: json['achievements'] != null
          ? (json['achievements'] as List)
              .map((e) =>
                  UserProfileAchievement.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    bool? isOnline,
    DateTime? joinedAt,
    UserProfileStats? stats,
    UserProfileCrew? crew,
    List<UserProfileVehicle>? garage,
    List<UserProfileAchievement>? achievements,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isOnline: isOnline ?? this.isOnline,
      joinedAt: joinedAt ?? this.joinedAt,
      stats: stats ?? this.stats,
      crew: crew ?? this.crew,
      garage: garage ?? this.garage,
      achievements: achievements ?? this.achievements,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        avatarUrl,
        bannerUrl,
        isOnline,
        joinedAt,
        stats,
        crew,
        garage,
        achievements,
      ];
}

/// Estatísticas do perfil do usuário
class UserProfileStats extends Equatable {
  const UserProfileStats({
    this.totalEvents = 0,
    this.totalCars = 0,
    this.totalBadges = 0,
  });

  final int totalEvents;
  final int totalCars;
  final int totalBadges;

  factory UserProfileStats.fromJson(Map<String, dynamic> json) {
    return UserProfileStats(
      totalEvents: json['totalEvents'] as int? ?? 0,
      totalCars: json['totalCars'] as int? ?? 0,
      totalBadges: json['totalBadges'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalEvents, totalCars, totalBadges];
}

/// Informações da crew do usuário
class UserProfileCrew extends Equatable {
  const UserProfileCrew({
    required this.id,
    required this.name,
    required this.tag,
    this.insigniaUrl,
    this.isLeader = false,
  });

  final String id;
  final String name;
  final String tag;
  final String? insigniaUrl;
  final bool isLeader;

  factory UserProfileCrew.fromJson(Map<String, dynamic> json) {
    return UserProfileCrew(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
      insigniaUrl: json['insigniaUrl'] as String?,
      isLeader: json['isLeader'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, tag, insigniaUrl, isLeader];
}

/// Veículo da garagem do usuário
class UserProfileVehicle extends Equatable {
  const UserProfileVehicle({
    required this.id,
    this.nickname,
    this.fullName,
    this.year,
    this.color,
    this.specs,
    this.thumbnailUrl,
  });

  final String id;
  final String? nickname;
  final String? fullName;
  final int? year;
  final String? color;
  final UserProfileVehicleSpecs? specs;
  final String? thumbnailUrl;

  factory UserProfileVehicle.fromJson(Map<String, dynamic> json) {
    return UserProfileVehicle(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname'] as String?,
      fullName: json['fullName'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      specs: json['specs'] != null
          ? UserProfileVehicleSpecs.fromJson(
              json['specs'] as Map<String, dynamic>)
          : null,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, nickname, fullName, year, color, specs, thumbnailUrl];
}

/// Especificações do veículo
class UserProfileVehicleSpecs extends Equatable {
  const UserProfileVehicleSpecs({
    this.engine,
    this.horsepower,
    this.transmission,
  });

  final String? engine;
  final int? horsepower;
  final Map<String, dynamic>? transmission;

  factory UserProfileVehicleSpecs.fromJson(Map<String, dynamic> json) {
    return UserProfileVehicleSpecs(
      engine: json['engine'] as String?,
      horsepower: json['horsepower'] as int?,
      transmission: json['transmission'] != null
          ? Map<String, dynamic>.from(json['transmission'] as Map)
          : null,
    );
  }

  @override
  List<Object?> get props => [engine, horsepower, transmission];
}

/// Achievement/Badge do usuário
class UserProfileAchievement extends Equatable {
  const UserProfileAchievement({
    required this.id,
    required this.name,
    this.imageUrl,
    this.acquiredAt,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final DateTime? acquiredAt;

  factory UserProfileAchievement.fromJson(Map<String, dynamic> json) {
    return UserProfileAchievement(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl'] as String?,
      acquiredAt: _parseDate(json['acquiredAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [id, name, imageUrl, acquiredAt];
}
