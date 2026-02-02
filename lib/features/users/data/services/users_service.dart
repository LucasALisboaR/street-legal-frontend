import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/profile/data/models/user_profile_model.dart';
import 'package:gearhead_br/features/users/data/models/user_model.dart';

/// Service para operações de usuário no backend
class UsersService extends BaseDataSource {
  UsersService(super.apiClient);

  static const Duration _profileCacheTtl = Duration(minutes: 10);
  UserProfileModel? _cachedProfile;
  DateTime? _lastProfileFetchedAt;
  Future<Either<ApiError, UserProfileModel>>? _profileRequest;

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

  Future<Either<ApiError, UserProfileModel>> getUserProfile(
    String userId, {
    bool force = false,
  }) async {
    if (!force && _isProfileCacheFresh()) {
      return Right(_cachedProfile!);
    }

    if (_profileRequest != null) {
      return _profileRequest!;
    }

    final request = executeRequest<UserProfileModel>(
      request: () => apiClient.get(ApiEndpoints.userById(userId)),
      fromJson: (json) =>
          UserProfileModel.fromJson(json as Map<String, dynamic>),
    );

    _profileRequest = request;
    final result = await request;
    _profileRequest = null;

    return result.fold(
      (error) => Left(error),
      (profile) {
        _cacheProfile(profile);
        return Right(profile);
      },
    );
  }

  Future<Either<ApiError, UserProfileModel>> uploadPicture(
    String userId,
    File imageFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Usar dio diretamente e remover Content-Type para FormData
      // O Dio define automaticamente multipart/form-data com boundary
      final response = await apiClient.dio.post<dynamic>(
        ApiEndpoints.updateUserPicture(userId),
        data: formData,
        options: Options(
          headers: {
            // Remover Content-Type - Dio define automaticamente para FormData
            'Content-Type': '', // String vazia remove o header padrão
          },
        ),
      );

      final data = response.data;
      final profile = _parseProfileResponse(data);
      _cacheProfile(profile);
      return Right(profile);
    } catch (e) {
      return handleError<UserProfileModel>(e);
    }
  }

  Future<Either<ApiError, UserProfileModel>> uploadBanner(
    String userId,
    File imageFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Usar dio diretamente e remover Content-Type para FormData
      // O Dio define automaticamente multipart/form-data com boundary
      final response = await apiClient.dio.post<dynamic>(
        ApiEndpoints.updateUserBanner(userId),
        data: formData,
        options: Options(
          headers: {
            // Remover Content-Type - Dio define automaticamente para FormData
            'Content-Type': '', // String vazia remove o header padrão
          },
        ),
      );

      final data = response.data;
      final profile = _parseProfileResponse(data);
      _cacheProfile(profile);
      return Right(profile);
    } catch (e) {
      return handleError<UserProfileModel>(e);
    }
  }

  Future<Either<ApiError, UserProfileModel?>> updateProfile({
    required String userId,
    String? name,
    String? bio,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (bio != null) payload['bio'] = bio;

    try {
      final response = await apiClient.patch<dynamic>(
        ApiEndpoints.userById(userId),
        data: payload,
      );
      
      // Verificar se a resposta foi bem-sucedida (status 200-299)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final cachedProfile = _cachedProfile;
        if (cachedProfile != null) {
          final updatedProfile = cachedProfile.copyWith(
            name: name ?? cachedProfile.name,
            bio: bio ?? cachedProfile.bio,
          );
          _cacheProfile(updatedProfile);
          return Right(updatedProfile);
        }
        return const Right(null);
      }

      return Left(ApiError.fromResponse(response.data, response.statusCode));
    } catch (e) {
      return handleError<UserProfileModel?>(e);
    }
  }

  UserProfileModel? getCachedProfile() => _cachedProfile;

  void updateCachedProfile(UserProfileModel profile) {
    _cacheProfile(profile);
  }

  bool _isProfileCacheFresh() {
    if (_cachedProfile == null || _lastProfileFetchedAt == null) return false;
    return DateTime.now().difference(_lastProfileFetchedAt!) < _profileCacheTtl;
  }

  void _cacheProfile(UserProfileModel profile) {
    _cachedProfile = profile;
    _lastProfileFetchedAt = DateTime.now();
  }

  UserProfileModel _parseProfileResponse(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return UserProfileModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }
}
