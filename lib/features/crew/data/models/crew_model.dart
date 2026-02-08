import 'package:gearhead_br/features/crew/domain/entities/crew_entity.dart';

class CrewModel {
  const CrewModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.description,
    this.imageUrl,
    this.memberIds = const [],
    this.adminIds = const [],
    this.city,
    this.state,
    this.isPublic = true,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final List<String> memberIds;
  final List<String> adminIds;
  final String? city;
  final String? state;
  final bool isPublic;
  final DateTime createdAt;

  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: json['description'] as String?,
      imageUrl: (json['imageUrl'] ?? json['avatarUrl'])?.toString(),
      ownerId: (json['ownerId'] ?? json['creatorId'] ?? '').toString(),
      memberIds: _parseStringList(json['memberIds'] ?? json['members'] ?? const []),
      adminIds: _parseStringList(json['adminIds'] ?? json['admins'] ?? const []),
      city: json['city'] as String?,
      state: json['state'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
    );
  }

  CrewEntity toEntity() {
    return CrewEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      ownerId: ownerId,
      memberIds: memberIds,
      adminIds: adminIds,
      city: city,
      state: state,
      isPublic: isPublic,
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
}
