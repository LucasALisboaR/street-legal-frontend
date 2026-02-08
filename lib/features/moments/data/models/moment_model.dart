import 'package:gearhead_br/features/moments/domain/entities/moment_entity.dart';

class MomentModel {
  const MomentModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.userDisplayName,
    this.userAvatarUrl,
    this.vehicleId,
    this.vehicleName,
    this.caption,
    this.imageUrls = const [],
    this.likeUserIds = const [],
    this.commentCount = 0,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  final String id;
  final String userId;
  final String? userDisplayName;
  final String? userAvatarUrl;
  final String? vehicleId;
  final String? vehicleName;
  final String? caption;
  final List<String> imageUrls;
  final List<String> likeUserIds;
  final int commentCount;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime createdAt;

  factory MomentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userData = user is Map<String, dynamic> ? user : null;
    return MomentModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? userData?['id'] ?? '').toString(),
      userDisplayName: (json['userDisplayName'] ??
              userData?['name'] ??
              userData?['username'])
          ?.toString(),
      userAvatarUrl:
          (json['userAvatarUrl'] ?? userData?['photoUrl'] ?? userData?['avatar'])
              ?.toString(),
      vehicleId: (json['vehicleId'] ?? json['carId'])?.toString(),
      vehicleName: (json['vehicleName'] ?? json['carName'])?.toString(),
      caption: json['caption']?.toString(),
      imageUrls: _parseStringList(json['imageUrls'] ?? json['images'] ?? const []),
      likeUserIds:
          _parseStringList(json['likeUserIds'] ?? json['likes'] ?? const []),
      commentCount: _parseInt(json['commentCount'] ?? json['comments'] ?? 0),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      locationName: (json['locationName'] ?? json['location'])?.toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
    );
  }

  MomentEntity toEntity() {
    return MomentEntity(
      id: id,
      userId: userId,
      userDisplayName: userDisplayName,
      userAvatarUrl: userAvatarUrl,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      caption: caption,
      imageUrls: imageUrls,
      likeUserIds: likeUserIds,
      commentCount: commentCount,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      createdAt: createdAt,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
