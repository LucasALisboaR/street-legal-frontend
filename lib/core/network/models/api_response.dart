/// Modelo genérico de resposta da API
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.message,
    this.success = true,
  });

  final T data;
  final String? message;
  final bool success;

  /// Cria ApiResponse a partir de uma resposta HTTP
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: fromJsonT(json['data']),
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'data': toJsonT(data),
      if (message != null) 'message': message,
      'success': success,
    };
  }
}

