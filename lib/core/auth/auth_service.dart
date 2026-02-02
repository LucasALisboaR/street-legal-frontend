import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';

/// Serviço central de autenticação para logout global
class AuthService {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required SessionStorage sessionStorage,
  })  : _firebaseAuth = firebaseAuth,
        _sessionStorage = sessionStorage;

  final FirebaseAuth _firebaseAuth;
  final SessionStorage _sessionStorage;

  Future<void> logout({bool redirectToLogin = true}) async {
    await _firebaseAuth.signOut();
    await _sessionStorage.clear();

    if (redirectToLogin) {
      AppRouter.router.go(AppRouter.login);
    }
  }
}
