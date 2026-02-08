import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/auth/data/models/auth_session_model.dart';

class AuthApiService extends BaseDataSource {
  AuthApiService(super.apiClient);

  Future<Either<ApiError, AuthSessionModel>> login({
    required String email,
    required String password,
  }) async {
    return executeRequest<AuthSessionModel>(
      request: () => apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      ),
      fromJson: (json) => AuthSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<Either<ApiError, AuthSessionModel>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return executeRequest<AuthSessionModel>(
      request: () => apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          if (displayName != null) 'name': displayName,
        },
      ),
      fromJson: (json) => AuthSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<Either<ApiError, AuthSessionModel>> refreshToken({
    required String refreshToken,
  }) async {
    return executeRequest<AuthSessionModel>(
      request: () => apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      ),
      fromJson: (json) => AuthSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  Future<Either<ApiError, void>> forgotPassword({
    required String email,
  }) async {
    return executeRequest<void>(
      request: () => apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      ),
      fromJson: (_) => null,
    );
  }

  Future<Either<ApiError, void>> logout() async {
    return executeRequest<void>(
      request: () => apiClient.post(ApiEndpoints.logout),
      fromJson: (_) => null,
    );
  }
}
