import 'package:dio/dio.dart';

/// Interceptor para tratamento centralizado de erros HTTP
/// 
/// Converte erros do Dio em exceções customizadas da aplicação
class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // O tratamento de erro específico será feito nos repositórios
    // Este interceptor apenas garante que erros sejam formatados consistentemente
    
    // Log do erro para debug
    if (err.response != null) {
      // Erro com resposta do servidor
      final statusCode = err.response?.statusCode;
      final data = err.response?.data;
      
      // Você pode adicionar lógica adicional aqui, como:
      // - Refresh token em caso de 401
      // - Retry automático em caso de 503
      // - Logging específico de erros
    } else {
      // Erro de conexão/timeout
      // Você pode adicionar lógica de retry aqui
    }

    return handler.next(err);
  }
}

