import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';

/// Parâmetros para login com e-mail
class LoginParams {

  const LoginParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}

/// Use case para login com e-mail e senha
class LoginUseCase {

  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call(LoginParams params) async {
    return await _repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

