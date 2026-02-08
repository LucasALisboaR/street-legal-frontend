import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';

class MeetupModel {
  const MeetupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.organizerId,
    this.endTime,
    this.participantIds = const [],
    this.coverImageUrl,
    this.isPublic = true,
    this.color,
  });

  final String id;
  final String name;
  final String description;
  final LocationEntity location;
  final DateTime startTime;
  final DateTime? endTime;
  final String organizerId;
  final List<String> participantIds;
  final String? coverImageUrl;
  final bool isPublic;
  final String? color;

  factory MeetupModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final locationData = location is Map<String, dynamic> ? location : json;
    return MeetupModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: LocationEntity(
        latitude: _parseDouble(locationData['latitude'] ?? locationData['lat']) ?? 0.0,
        longitude: _parseDouble(locationData['longitude'] ?? locationData['lng']) ?? 0.0,
        address: (locationData['address'] ?? locationData['locationName'])?.toString(),
        timestamp: _parseDate(json['createdAt'] ?? json['created_at']) ??
            DateTime.now(),
      ),
      startTime: _parseDate(json['startTime'] ?? json['start_date']) ??
          DateTime.now(),
      endTime: _parseDate(json['endTime'] ?? json['end_date']),
      organizerId: (json['organizerId'] ?? json['ownerId'] ?? '').toString(),
      participantIds:
          _parseStringList(json['participantIds'] ?? json['participants'] ?? const []),
      coverImageUrl: (json['coverImageUrl'] ?? json['imageUrl'])?.toString(),
      isPublic: json['isPublic'] as bool? ?? true,
      color: json['color']?.toString(),
    );
  }

  MeetupEntity toEntity() {
    return MeetupEntity(
      id: id,
      name: name,
      description: description,
      location: location,
      startTime: startTime,
      endTime: endTime,
      organizerId: organizerId,
      participantIds: participantIds,
      coverImageUrl: coverImageUrl,
      isPublic: isPublic,
      color: color,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
