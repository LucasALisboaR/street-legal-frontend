import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';

/// Classe base para todos os data sources
/// 
/// Fornece métodos auxiliares para tratamento de erros e requisições HTTP
abstract class BaseDataSource {
  BaseDataSource(this.apiClient);

  final ApiClient apiClient;

  /// Trata erros do Dio e converte em ApiError
  Either<ApiError, T> handleError<T>(dynamic error) {
    if (error is DioException) {
      return Left(_handleDioException(error));
    }

    return Left(ApiError.fromDioException(error));
  }

  /// Converte DioException em ApiError
  ApiError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError.timeout();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 401:
            return ApiError.unauthorized();
          case 404:
            return ApiError.notFound();
          case 500:
          case 502:
          case 503:
            return ApiError.serverError(statusCode);
          default:
            return ApiError.fromResponse(data, statusCode);
        }

      case DioExceptionType.cancel:
        return const ApiError(
          message: 'Requisição cancelada',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return ApiError.connectionError();

      case DioExceptionType.badCertificate:
        return const ApiError(
          message: 'Certificado inválido',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        return ApiError.connectionError();
    }
  }

  /// Executa uma requisição e trata erros automaticamente
  Future<Either<ApiError, T>> executeRequest<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return Right(fromJson(data['data']));
      }

      return Right(fromJson(data));
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Executa uma requisição que retorna uma lista
  Future<Either<ApiError, List<T>>> executeListRequest<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final list = data['data'] as List;
        return Right(list.map((item) => fromJson(item)).toList());
      }

      if (data is List) {
        return Right(data.map((item) => fromJson(item)).toList());
      }

      return Right([]);
    } catch (e) {
      return handleError<List<T>>(e);
    }
  }
}

