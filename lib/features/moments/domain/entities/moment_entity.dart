import 'package:equatable/equatable.dart';

/// Entidade de Momento (post/foto)
class MomentEntity extends Equatable {

  const MomentEntity({
    required this.id,
    required this.userId,
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
    required this.createdAt,
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

  int get likeCount => likeUserIds.length;

  bool isLikedBy(String userId) => likeUserIds.contains(userId);

  @override
  List<Object?> get props => [
        id,
        userId,
        userDisplayName,
        userAvatarUrl,
        vehicleId,
        vehicleName,
        caption,
        imageUrls,
        likeUserIds,
        commentCount,
        latitude,
        longitude,
        locationName,
        createdAt,
      ];

  MomentEntity copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? vehicleId,
    String? vehicleName,
    String? caption,
    List<String>? imageUrls,
    List<String>? likeUserIds,
    int? commentCount,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? createdAt,
  }) {
    return MomentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      caption: caption ?? this.caption,
      imageUrls: imageUrls ?? this.imageUrls,
      likeUserIds: likeUserIds ?? this.likeUserIds,
      commentCount: commentCount ?? this.commentCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
