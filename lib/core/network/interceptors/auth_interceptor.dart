import 'package:dio/dio.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';

/// Interceptor para adicionar token de autenticação nas requisições
/// 
/// Obtém o token salvo na sessão e adiciona no header Authorization
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionStorage);

  final SessionStorage _sessionStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
