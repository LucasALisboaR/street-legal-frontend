import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/moments/data/models/moment_model.dart';
import 'package:gearhead_br/features/moments/domain/entities/moment_entity.dart';

class MomentsService extends BaseDataSource {
  MomentsService(super.apiClient);

  Future<Either<ApiError, List<MomentEntity>>> getMoments() async {
    final result = await executeListRequest<MomentModel>(
      request: () => apiClient.get(ApiEndpoints.moments),
      fromJson: (json) => MomentModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  Future<Either<ApiError, MomentEntity>> createMoment(
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<MomentModel>(
      request: () => apiClient.post(
        ApiEndpoints.moments,
        data: payload,
      ),
      fromJson: (json) => MomentModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, MomentEntity>> likeMoment(String momentId) async {
    final result = await executeRequest<MomentModel>(
      request: () => apiClient.post(ApiEndpoints.likeMoment(momentId)),
      fromJson: (json) => MomentModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, MomentEntity>> unlikeMoment(String momentId) async {
    final result = await executeRequest<MomentModel>(
      request: () => apiClient.post(ApiEndpoints.unlikeMoment(momentId)),
      fromJson: (json) => MomentModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }
}
