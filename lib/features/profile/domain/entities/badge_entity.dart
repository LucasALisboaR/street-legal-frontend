import 'package:equatable/equatable.dart';

/// Entidade de Badge
/// Representa um badge conquistado pelo usuário ao participar de eventos oficiais
class BadgeEntity extends Equatable {
  const BadgeEntity({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.badgeImageUrl,
    this.eventDescription,
    this.eventLocation,
    required this.earnedAt,
  });
  
  final String id;
  final String userId;
  final String eventId;
  final String eventName;
  final DateTime eventDate;
  final String badgeImageUrl;
  final String? eventDescription;
  final String? eventLocation;
  final DateTime earnedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        eventId,
        eventName,
        eventDate,
        badgeImageUrl,
        eventDescription,
        eventLocation,
        earnedAt,
      ];

  BadgeEntity copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? eventName,
    DateTime? eventDate,
    String? badgeImageUrl,
    String? eventDescription,
    String? eventLocation,
    DateTime? earnedAt,
  }) {
    return BadgeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      badgeImageUrl: badgeImageUrl ?? this.badgeImageUrl,
      eventDescription: eventDescription ?? this.eventDescription,
      eventLocation: eventLocation ?? this.eventLocation,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}

