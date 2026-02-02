import 'package:dio/dio.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';

/// Interceptor para tratamento centralizado de erros HTTP
/// 
/// Converte erros do Dio em exceções customizadas da aplicação
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._authService);

  final AuthService _authService;

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

      if (statusCode == 401 || statusCode == 403) {
        _authService.logout();
      }
    }

    return handler.next(err);
  }
}
