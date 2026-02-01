import 'package:equatable/equatable.dart';

/// Entidade de localização
/// Representa um ponto no mapa
class LocationEntity extends Equatable {

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp, this.address,
  });
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  @override
  List<Object?> get props => [latitude, longitude, address, timestamp];

  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Entidade de evento/encontro
class MeetupEntity extends Equatable {

  const MeetupEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.organizerId, this.endTime,
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
  final String? color; // Cor do evento em formato hex (ex: "#FF4500")

  int get participantCount => participantIds.length;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        startTime,
        endTime,
        organizerId,
        participantIds,
        coverImageUrl,
        isPublic,
        color,
      ];
}

