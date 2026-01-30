import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';

/// Parâmetros para registro
class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    this.displayName,
  });
  final String email;
  final String password;
  final String? displayName;
}

/// Use case para registro de novo usuário
class RegisterUseCase {
  RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call(RegisterParams params) async {
    return _repository.register(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}



