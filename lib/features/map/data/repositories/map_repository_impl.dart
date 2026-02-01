import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'dart:math';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';
import 'package:gearhead_br/features/map/domain/utils/geo_utils.dart';

/// Implementação do repositório do mapa com geolocator
class MapRepositoryImpl implements MapRepository {
  final LocationService _locationService;

  MapRepositoryImpl(this._locationService);
  static const double _minNearbyDistanceMeters = 500;

  Random _seededRandom(double latitude, double longitude, int salt) {
    final latSeed = (latitude * 10000).round();
    final lonSeed = (longitude * 10000).round();
    return Random(latSeed ^ (lonSeed << 1) ^ salt);
  }

  @override
  Future<Either<MapFailure, LocationEntity>> getCurrentLocation() async {
    try {
      // Verifica se o serviço de localização está habilitado
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        return const Left(LocationServiceFailure());
      }

      // Verifica e solicita permissões
      final hasPermission = await _locationService.checkAndRequestPermissions();
      if (!hasPermission) {
        return const Left(LocationPermissionFailure());
      }

      // Obtém a localização atual
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        return const Left(LocationPermissionFailure());
      }

      return Right(LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        address: null, // Pode ser implementado com geocoding depois
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return Left(LocationServiceFailure());
    }
  }

  @override
  Future<Either<MapFailure, List<MeetupEntity>>> getNearbyMeetups({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock existente reutilizado, agora adaptado para ancorar nos arredores do usuário.
    final anchor = MapPoint(latitude: latitude, longitude: longitude);
    final radiusMeters = (radiusKm * 1000).clamp(500, 2000).toDouble();
    final rng = _seededRandom(latitude, longitude, 11);

    final meetupLocations = [
      randomOffsetAround(
        origin: anchor,
        minDistanceMeters: _minNearbyDistanceMeters,
        maxDistanceMeters: radiusMeters,
        random: rng,
      ),
      randomOffsetAround(
        origin: anchor,
        minDistanceMeters: _minNearbyDistanceMeters,
        maxDistanceMeters: radiusMeters,
        random: rng,
      ),
    ];

    // Mock: retorna alguns encontros de exemplo
    return Right([
      MeetupEntity(
        id: '1',
        name: 'Encontro de Opalas',
        description: 'Encontro semanal de entusiastas de Opala',
        location: LocationEntity(
          latitude: meetupLocations[0].latitude,
          longitude: meetupLocations[0].longitude,
          address: 'Praça da Sé, São Paulo',
          timestamp: DateTime.now(),
        ),
        startTime: DateTime.now().add(const Duration(hours: 3)),
        organizerId: 'user-1',
        participantIds: const ['user-2', 'user-3', 'user-4'],
        color: '#FF4500', // Laranja (accent)
      ),
      MeetupEntity(
        id: '2',
        name: 'Role VW Ar',
        description: 'Fusca, Kombi, Brasilia e toda linha VW refrigerada a ar',
        location: LocationEntity(
          latitude: meetupLocations[1].latitude,
          longitude: meetupLocations[1].longitude,
          address: 'Ibirapuera, São Paulo',
          timestamp: DateTime.now(),
        ),
        startTime: DateTime.now().add(const Duration(days: 1)),
        organizerId: 'user-5',
        participantIds: const ['user-6', 'user-7'],
        color: '#00E676', // verde (success)
      ),
    ]);
  }

  @override
  Future<Either<MapFailure, List<Map<String, dynamic>>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock existente reutilizado, agora adaptado para coordenadas próximas ao usuário.
    final anchor = MapPoint(latitude: latitude, longitude: longitude);
    final radiusMeters = (radiusKm * 1000).clamp(500, 2000).toDouble();
    final rng = _seededRandom(latitude, longitude, 22);

    final userLocations = [
      randomOffsetAround(
        origin: anchor,
        minDistanceMeters: _minNearbyDistanceMeters,
        maxDistanceMeters: radiusMeters,
        random: rng,
      ),
      randomOffsetAround(
        origin: anchor,
        minDistanceMeters: _minNearbyDistanceMeters,
        maxDistanceMeters: radiusMeters,
        random: rng,
      ),
    ];

    final distances = userLocations
        .map((point) => haversineDistanceMeters(anchor, point) / 1000)
        .toList();

    // Mock: retorna alguns usuários próximos
    return Right([
      {
        'id': 'user-2',
        'displayName': 'Carlos Turbo',
        'vehicle': 'Civic Si',
        'distance': distances[0],
        'latitude': userLocations[0].latitude,
        'longitude': userLocations[0].longitude,
      },
      {
        'id': 'user-3',
        'displayName': 'Pedro V8',
        'vehicle': 'Mustang GT',
        'distance': distances[1],
        'latitude': userLocations[1].latitude,
        'longitude': userLocations[1].longitude,
      },
    ]);
  }

  @override
  Future<Either<MapFailure, void>> updateUserLocation(LocationEntity location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }
}
