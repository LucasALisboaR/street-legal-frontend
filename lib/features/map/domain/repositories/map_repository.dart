import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';

/// Falhas relacionadas ao mapa
abstract class MapFailure {
  const MapFailure(this.message);
  final String message;
}

class LocationPermissionFailure extends MapFailure {
  const LocationPermissionFailure() : super('Permissão de localização negada');
}

class LocationServiceFailure extends MapFailure {
  const LocationServiceFailure() : super('Serviço de localização desativado');
}

class MapNetworkFailure extends MapFailure {
  const MapNetworkFailure() : super('Erro de conexão');
}

/// Interface do repositório do mapa
abstract class MapRepository {
  /// Obtém a localização atual do usuário
  Future<Either<MapFailure, LocationEntity>> getCurrentLocation();

  /// Busca encontros próximos
  Future<Either<MapFailure, List<MeetupEntity>>> getNearbyMeetups({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });

  /// Busca usuários próximos
  Future<Either<MapFailure, List<Map<String, dynamic>>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  });

  /// Atualiza a localização do usuário
  Future<Either<MapFailure, void>> updateUserLocation(LocationEntity location);
}

