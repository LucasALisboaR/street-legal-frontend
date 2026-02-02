import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/users/data/models/user_model.dart';

/// Service para operações de usuário no backend
class UsersService extends BaseDataSource {
  UsersService(super.apiClient);

  Future<Either<ApiError, UserModel>> sync() {
    return executeRequest<UserModel>(
      request: () => apiClient.post(ApiEndpoints.usersSync),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, UserModel>> createUser(
    Map<String, dynamic> payload,
  ) {
    return executeRequest<UserModel>(
      request: () => apiClient.post(ApiEndpoints.users, data: payload),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, UserModel>> getUser(String id) {
    return executeRequest<UserModel>(
      request: () => apiClient.get(ApiEndpoints.userById(id)),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, UserModel>> updateUser(
    String id,
    Map<String, dynamic> payload,
  ) {
    return executeRequest<UserModel>(
      request: () => apiClient.patch(ApiEndpoints.userById(id), data: payload),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, List<UserModel>>> getCrewUsers({
    required String crewId,
    int? page,
    int? limit,
  }) {
    return executeListRequest<UserModel>(
      request: () => apiClient.get(
        ApiEndpoints.usersByCrew(crewId),
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      ),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
