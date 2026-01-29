import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';

/// Implementação mock do repositório do mapa
/// TODO: Substituir por implementação real com geolocator
class MapRepositoryImpl implements MapRepository {
  @override
  Future<Either<MapFailure, LocationEntity>> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: retorna localização de São Paulo
    return Right(LocationEntity(
      latitude: -23.550520,
      longitude: -46.633308,
      address: 'São Paulo, SP',
      timestamp: DateTime.now(),
    ),);
  }

  @override
  Future<Either<MapFailure, List<MeetupEntity>>> getNearbyMeetups({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: retorna alguns encontros de exemplo
    return Right([
      MeetupEntity(
        id: '1',
        name: 'Encontro de Opalas',
        description: 'Encontro semanal de entusiastas de Opala',
        location: LocationEntity(
          latitude: latitude + 0.01,
          longitude: longitude + 0.01,
          address: 'Praça da Sé, São Paulo',
          timestamp: DateTime.now(),
        ),
        startTime: DateTime.now().add(const Duration(hours: 3)),
        organizerId: 'user-1',
        participantIds: const ['user-2', 'user-3', 'user-4'],
      ),
      MeetupEntity(
        id: '2',
        name: 'Role VW Ar',
        description: 'Fusca, Kombi, Brasilia e toda linha VW refrigerada a ar',
        location: LocationEntity(
          latitude: latitude - 0.02,
          longitude: longitude + 0.02,
          address: 'Ibirapuera, São Paulo',
          timestamp: DateTime.now(),
        ),
        startTime: DateTime.now().add(const Duration(days: 1)),
        organizerId: 'user-5',
        participantIds: const ['user-6', 'user-7'],
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
    
    // Mock: retorna alguns usuários próximos
    return const Right([
      {
        'id': 'user-2',
        'displayName': 'Carlos Turbo',
        'vehicle': 'Civic Si',
        'distance': 0.5,
      },
      {
        'id': 'user-3',
        'displayName': 'Pedro V8',
        'vehicle': 'Mustang GT',
        'distance': 1.2,
      },
    ]);
  }

  @override
  Future<Either<MapFailure, void>> updateUserLocation(LocationEntity location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }
}

