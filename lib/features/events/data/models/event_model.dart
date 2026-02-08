import 'package:gearhead_br/features/events/domain/entities/event_entity.dart';

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.organizerId,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.createdAt,
    this.description,
    this.imageUrl,
    this.crewId,
    this.address,
    this.endDate,
    this.participantIds = const [],
    this.maxParticipants,
    this.isPublic = true,
    this.type = EventType.meetup,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String organizerId;
  final String? crewId;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> participantIds;
  final int? maxParticipants;
  final bool isPublic;
  final EventType type;
  final DateTime createdAt;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final coordinates = location is Map<String, dynamic> ? location : null;
    return EventModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: json['description'] as String?,
      imageUrl: (json['imageUrl'] ?? json['coverImageUrl'])?.toString(),
      organizerId: (json['organizerId'] ?? json['ownerId'] ?? '').toString(),
      crewId: (json['crewId'] ?? json['crew_id'])?.toString(),
      latitude: _parseDouble(
        json['latitude'] ??
            coordinates?['latitude'] ??
            coordinates?['lat'] ??
            0,
      ),
      longitude: _parseDouble(
        json['longitude'] ??
            coordinates?['longitude'] ??
            coordinates?['lng'] ??
            0,
      ),
      address: (json['address'] ?? json['locationName'])?.toString(),
      startDate: _parseDate(json['startDate'] ?? json['start_time']) ??
          DateTime.now(),
      endDate: _parseDate(json['endDate'] ?? json['end_time']),
      participantIds: _parseStringList(
        json['participantIds'] ?? json['participants'] ?? const [],
      ),
      maxParticipants: _parseInt(json['maxParticipants']),
      isPublic: json['isPublic'] as bool? ?? true,
      type: _parseType(json['type'] ?? json['eventType']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
    );
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      organizerId: organizerId,
      crewId: crewId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      startDate: startDate,
      endDate: endDate,
      participantIds: participantIds,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      type: type,
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

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static EventType _parseType(dynamic value) {
    final normalized = value?.toString().toLowerCase();
    switch (normalized) {
      case 'carshow':
      case 'expo':
      case 'exposicao':
      case 'exhibition':
        return EventType.carshow;
      case 'cruise':
      case 'role':
      case 'rolê':
        return EventType.cruise;
      case 'race':
      case 'trackday':
      case 'track_day':
        return EventType.race;
      case 'workshop':
        return EventType.workshop;
      default:
        return EventType.meetup;
    }
  }
}
