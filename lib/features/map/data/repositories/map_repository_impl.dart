import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/data/services/map_service.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';

/// Implementação do repositório do mapa com geolocator e API
class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({
    required LocationService locationService,
    required MapService mapService,
  })  : _locationService = locationService,
        _mapService = mapService;

  final LocationService _locationService;
  final MapService _mapService;

  @override
  Future<Either<MapFailure, LocationEntity>> getCurrentLocation() async {
    try {
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        return const Left(LocationServiceFailure());
      }

      final hasPermission = await _locationService.checkAndRequestPermissions();
      if (!hasPermission) {
        return const Left(LocationPermissionFailure());
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        return const Left(LocationPermissionFailure());
      }

      return Right(LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        address: null,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      return Left(LocationServiceFailure());
    }
  }

  @override
  Future<Either<MapFailure, List<MeetupEntity>>> getNearbyMeetups({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    final result = await _mapService.getNearbyMeetups(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    return result.fold(
      (_) => const Left(MapNetworkFailure()),
      (meetups) => Right(meetups),
    );
  }

  @override
  Future<Either<MapFailure, List<Map<String, dynamic>>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    final result = await _mapService.getNearbyUsers(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    return result.fold(
      (_) => const Left(MapNetworkFailure()),
      (users) => Right(users),
    );
  }

  @override
  Future<Either<MapFailure, void>> updateUserLocation(
    LocationEntity location,
  ) async {
    final result = await _mapService.updateUserLocation(location);
    return result.fold(
      (_) => const Left(MapNetworkFailure()),
      (_) => const Right(null),
    );
  }
}
