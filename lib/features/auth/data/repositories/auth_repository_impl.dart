import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';
import 'package:gearhead_br/features/auth/data/services/auth_api_service.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';

/// Implementação do repositório de autenticação com API
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiService authApiService,
    required SessionStorage sessionStorage,
  })  : _authApiService = authApiService,
        _sessionStorage = sessionStorage;

  final AuthApiService _authApiService;
  final SessionStorage _sessionStorage;

  AuthFailure _mapApiError(ApiError error) {
    switch (error.statusCode) {
      case 401:
        return const InvalidCredentialsFailure();
      case 404:
        return const UserNotFoundFailure();
      case 409:
        return const EmailAlreadyInUseFailure();
      case 422:
        return const WeakPasswordFailure();
      default:
        if (error.code == 'CONNECTION_ERROR' || error.code == 'TIMEOUT') {
          return const NetworkFailure();
        }
        return UnknownFailure(error.message);
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _authApiService.login(
      email: email,
      password: password,
    );

    return await result.fold(
      (error) async => Left(_mapApiError(error)),
      (session) async {
        await _sessionStorage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          expiresAt: session.expiresAt,
        );
        return Right(session.user);
      },
    );
  }

  // Login social removido temporariamente
  // @override
  // Future<Either<AuthFailure, UserEntity>> loginWithSocial({
  //   required SocialAuthType type,
  // }) async {
  //   return const Left(UnknownFailure('Login social não disponível no momento'));
  // }

  @override
  Future<Either<AuthFailure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final result = await _authApiService.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    return await result.fold(
      (error) async => Left(_mapApiError(error)),
      (session) async {
        await _sessionStorage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          expiresAt: session.expiresAt,
        );
        return Right(session.user);
      },
    );
  }

  @override
  Future<Either<AuthFailure, void>> forgotPassword({
    required String email,
  }) async {
    final result = await _authApiService.forgotPassword(email: email);
    return result.fold(
      (error) => Left(_mapApiError(error)),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    final result = await _authApiService.logout();
    await _sessionStorage.clear();
    return result.fold(
      (error) => Left(_mapApiError(error)),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    final storedUser = await _sessionStorage.getUser();
    if (storedUser == null) {
      return const Right(null);
    }
    return Right(UserEntity(
      id: storedUser.id,
      email: storedUser.email ?? '',
      displayName: storedUser.name ?? storedUser.username,
      photoUrl: storedUser.photoUrl,
      createdAt: storedUser.createdAt ?? DateTime.now(),
    ));
  }
}
