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
}

