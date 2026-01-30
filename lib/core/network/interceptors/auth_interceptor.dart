import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Interceptor para adicionar token de autenticação nas requisições
/// 
/// Obtém o token do Firebase Auth e adiciona no header Authorization
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obter token do Firebase Auth
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        if (token != null) {
          // Adicionar token no header Authorization
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Se houver erro ao obter token, continuar sem ele
        // O backend retornará 401 se necessário
      }
    }

    return handler.next(options);
  }
}

