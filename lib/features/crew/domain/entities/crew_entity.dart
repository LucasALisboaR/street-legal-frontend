import 'package:equatable/equatable.dart';

/// Entidade de Crew (grupo de entusiastas)
class CrewEntity extends Equatable {
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

  const CrewEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.ownerId,
    this.memberIds = const [],
    this.adminIds = const [],
    this.city,
    this.state,
    this.isPublic = true,
    required this.createdAt,
  });

  int get memberCount => memberIds.length;

  String get location => [city, state].where((e) => e != null).join(', ');

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        ownerId,
        memberIds,
        adminIds,
        city,
        state,
        isPublic,
        createdAt,
      ];

  CrewEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? ownerId,
    List<String>? memberIds,
    List<String>? adminIds,
    String? city,
    String? state,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return CrewEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      city: city ?? this.city,
      state: state ?? this.state,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

