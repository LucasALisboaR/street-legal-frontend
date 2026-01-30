import 'package:equatable/equatable.dart';

/// Modelo de erro retornado pela API
class ApiError extends Equatable {
  const ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.errors,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  /// Cria ApiError a partir de uma resposta DioException
  factory ApiError.fromDioException(dynamic error) {
    if (error is Map<String, dynamic>) {
      return ApiError(
        message: error['message'] as String? ?? 'Erro desconhecido',
        code: error['code'] as String?,
        statusCode: error['statusCode'] as int?,
        errors: error['errors'] as Map<String, List<String>>?,
      );
    }

    return const ApiError(message: 'Erro desconhecido');
  }

  /// Cria ApiError a partir de uma resposta HTTP
  factory ApiError.fromResponse(dynamic data, int? statusCode) {
    if (data is Map<String, dynamic>) {
      return ApiError(
        message: data['message'] as String? ?? 'Erro na requisição',
        code: data['code'] as String?,
        statusCode: statusCode,
        errors: data['errors'] as Map<String, List<String>>?,
      );
    }

    return ApiError(
      message: 'Erro na requisição',
      statusCode: statusCode,
    );
  }

  /// Cria ApiError para erro de conexão
  factory ApiError.connectionError() {
    return const ApiError(
      message: 'Erro de conexão. Verifique sua internet.',
      code: 'CONNECTION_ERROR',
    );
  }

  /// Cria ApiError para timeout
  factory ApiError.timeout() {
    return const ApiError(
      message: 'Tempo de espera esgotado. Tente novamente.',
      code: 'TIMEOUT',
    );
  }

  /// Cria ApiError para erro não autorizado
  factory ApiError.unauthorized() {
    return const ApiError(
      message: 'Não autorizado. Faça login novamente.',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  /// Cria ApiError para erro não encontrado
  factory ApiError.notFound() {
    return const ApiError(
      message: 'Recurso não encontrado.',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  /// Cria ApiError para erro de servidor
  factory ApiError.serverError(int? statusCode) {
    return ApiError(
      message: 'Erro no servidor. Tente novamente mais tarde.',
      code: 'SERVER_ERROR',
      statusCode: statusCode ?? 500,
    );
  }

  @override
  List<Object?> get props => [message, code, statusCode, errors];
}

