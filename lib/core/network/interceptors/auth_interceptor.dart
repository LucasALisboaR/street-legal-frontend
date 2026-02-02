import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';

/// Interceptor para adicionar token de autenticação nas requisições
/// 
/// Obtém o token do Firebase Auth e adiciona no header Authorization
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._firebaseAuth, this._authService);

  final FirebaseAuth _firebaseAuth;
  final AuthService _authService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obter token do Firebase Auth
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      await _authService.logout();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Usuário não autenticado',
        ),
      );
    }

    try {
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        await _authService.logout();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Token inválido',
          ),
        );
      }
      // Adicionar token no header Authorization
      options.headers['Authorization'] = 'Bearer $token';
    } catch (_) {
      await _authService.logout();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Falha ao obter token',
        ),
      );
    }

    return handler.next(options);
  }
}
