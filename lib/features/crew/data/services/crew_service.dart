import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/crew/data/models/crew_model.dart';
import 'package:gearhead_br/features/crew/domain/entities/crew_entity.dart';

class CrewService extends BaseDataSource {
  CrewService(super.apiClient);

  Future<Either<ApiError, List<CrewEntity>>> getCrews() async {
    final result = await executeListRequest<CrewModel>(
      request: () => apiClient.get(ApiEndpoints.crews),
      fromJson: (json) => CrewModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  Future<Either<ApiError, CrewEntity>> createCrew(
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<CrewModel>(
      request: () => apiClient.post(
        ApiEndpoints.crews,
        data: payload,
      ),
      fromJson: (json) => CrewModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, void>> joinCrew(String crewId) async {
    return executeRequest<void>(
      request: () => apiClient.post(ApiEndpoints.joinCrew(crewId)),
      fromJson: (_) => null,
    );
  }

  Future<Either<ApiError, void>> leaveCrew(String crewId) async {
    return executeRequest<void>(
      request: () => apiClient.post(ApiEndpoints.leaveCrew(crewId)),
      fromJson: (_) => null,
    );
  }
}
