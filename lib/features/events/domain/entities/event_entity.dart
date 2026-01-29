import 'package:equatable/equatable.dart';

/// Entidade de Evento automotivo
class EventEntity extends Equatable {
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

  const EventEntity({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.organizerId,
    this.crewId,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.startDate,
    this.endDate,
    this.participantIds = const [],
    this.maxParticipants,
    this.isPublic = true,
    this.type = EventType.meetup,
    required this.createdAt,
  });

  int get participantCount => participantIds.length;

  bool get isFull =>
      maxParticipants != null && participantCount >= maxParticipants!;

  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && (endDate?.isAfter(now) ?? true);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        organizerId,
        crewId,
        latitude,
        longitude,
        address,
        startDate,
        endDate,
        participantIds,
        maxParticipants,
        isPublic,
        type,
        createdAt,
      ];
}

enum EventType {
  meetup,      // Encontro casual
  carshow,     // Exposição
  cruise,      // Rolê/Passeio
  race,        // Arrancada/Track day
  workshop,    // Oficina/Tutorial
}

extension EventTypeExtension on EventType {
  String get label => switch (this) {
        EventType.meetup => 'Encontro',
        EventType.carshow => 'Exposição',
        EventType.cruise => 'Rolê',
        EventType.race => 'Track Day',
        EventType.workshop => 'Workshop',
      };

  String get emoji => switch (this) {
        EventType.meetup => '🚗',
        EventType.carshow => '🏆',
        EventType.cruise => '🛣️',
        EventType.race => '🏁',
        EventType.workshop => '🔧',
      };
}

