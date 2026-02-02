import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/garage/data/models/vehicle_model.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';

/// Service para operações de garagem no backend
class GarageService extends BaseDataSource {
  GarageService(super.apiClient);

  Future<Either<ApiError, List<VehicleEntity>>> getGarage(String userId) async {
    final result = await executeListRequest<VehicleModel>(
      request: () => apiClient.get(ApiEndpoints.garageByUser(userId)),
      fromJson: (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  Future<Either<ApiError, VehicleEntity>> addVehicle(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<VehicleModel>(
      request: () => apiClient.post(
        ApiEndpoints.garageByUser(userId),
        data: payload,
      ),
      fromJson: (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, VehicleEntity>> updateVehicle(
    String userId,
    String carId,
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<VehicleModel>(
      request: () => apiClient.patch(
        ApiEndpoints.garageVehicle(userId, carId),
        data: payload,
      ),
      fromJson: (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, void>> deleteVehicle(
    String userId,
    String carId,
  ) async {
    return executeRequest<void>(
      request: () => apiClient.delete(ApiEndpoints.garageVehicle(userId, carId)),
      fromJson: (_) => null,
    );
  }
}
