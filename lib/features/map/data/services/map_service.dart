import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/map/data/models/meetup_model.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';

class MapService extends BaseDataSource {
  MapService(super.apiClient);

  Future<Either<ApiError, List<MeetupEntity>>> getNearbyMeetups({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final result = await executeListRequest<MeetupModel>(
      request: () => apiClient.get(
        ApiEndpoints.nearbyLocations,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          'type': 'meetup',
        },
      ),
      fromJson: (json) => MeetupModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  Future<Either<ApiError, List<Map<String, dynamic>>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    return executeListRequest<Map<String, dynamic>>(
      request: () => apiClient.get(
        ApiEndpoints.nearbyLocations,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          'type': 'user',
        },
      ),
      fromJson: (json) => _normalizeUserMap(json as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, void>> updateUserLocation(
    LocationEntity location,
  ) async {
    return executeRequest<void>(
      request: () => apiClient.post(
        ApiEndpoints.userLocation,
        data: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timestamp': location.timestamp.toIso8601String(),
          if (location.address != null) 'address': location.address,
        },
      ),
      fromJson: (_) => null,
    );
  }

  Map<String, dynamic> _normalizeUserMap(Map<String, dynamic> json) {
    final location = json['location'];
    final locationData = location is Map<String, dynamic> ? location : json;
    return {
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'displayName': (json['displayName'] ??
              json['name'] ??
              json['username'] ??
              'Usuário')
          .toString(),
      'vehicle': (json['vehicle'] ?? json['vehicleName'] ?? '').toString(),
      'vehicleImageUrl': (json['vehicleImageUrl'] ?? json['vehicleImage'])
          ?.toString(),
      'latitude': _parseDouble(locationData['latitude'] ?? locationData['lat']) ?? 0.0,
      'longitude': _parseDouble(locationData['longitude'] ?? locationData['lng']) ?? 0.0,
      'distance': _parseDouble(json['distance'] ?? json['distanceKm']) ?? 0.0,
    };
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
