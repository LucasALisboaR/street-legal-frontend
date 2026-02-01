import 'package:equatable/equatable.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';

/// Entidade de usuário próximo exibido no mapa.
class MapUserEntity extends Equatable {
  const MapUserEntity({
    required this.id,
    required this.displayName,
    required this.vehicle,
    required this.location,
    required this.distanceKm,
  });

  final String id;
  final String displayName;
  final String vehicle;
  final MapPoint location;
  final double distanceKm;

  @override
  List<Object?> get props => [id, displayName, vehicle, location, distanceKm];

  factory MapUserEntity.fromMap(Map<String, dynamic> data) {
    return MapUserEntity(
      id: data['id'] as String,
      displayName: data['displayName'] as String,
      vehicle: data['vehicle'] as String? ?? '',
      location: MapPoint(
        latitude: data['latitude'] as double,
        longitude: data['longitude'] as double,
      ),
      distanceKm: (data['distance'] as num).toDouble(),
    );
  }
}
