import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';

/// Serviço central de autenticação para logout global
class AuthService {
  AuthService({
    required SessionStorage sessionStorage,
  }) : _sessionStorage = sessionStorage;

  final SessionStorage _sessionStorage;

  Future<void> logout({bool redirectToLogin = true}) async {
    await _sessionStorage.clear();

    if (redirectToLogin) {
      AppRouter.router.go(AppRouter.login);
    }
  }
}
