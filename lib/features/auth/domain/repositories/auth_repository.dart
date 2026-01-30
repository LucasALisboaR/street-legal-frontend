import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';

/// Tipos de autenticação social disponíveis
/// TODO: Reativar quando login social for implementado
// enum SocialAuthType {
//   google,
//   apple,
//   facebook,
// }

/// Falhas de autenticação
abstract class AuthFailure {
  const AuthFailure(this.message);
  final String message;
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('E-mail ou senha incorretos');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('Usuário não encontrado');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Este e-mail já está em uso');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('A senha é muito fraca');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Erro de conexão. Verifique sua internet');
}

class SocialAuthCancelledFailure extends AuthFailure {
  const SocialAuthCancelledFailure() : super('Login social cancelado');
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure([super.message = 'Ocorreu um erro inesperado']);
}

/// Interface do repositório de autenticação
/// Define os contratos para operações de auth
abstract class AuthRepository {
  /// Login com e-mail e senha
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login com provedor social
  /// TODO: Reativar quando login social for implementado
  // Future<Either<AuthFailure, UserEntity>> loginWithSocial({
  //   required SocialAuthType type,
  // });

  /// Registro de novo usuário
  Future<Either<AuthFailure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Recuperação de senha
  Future<Either<AuthFailure, void>> forgotPassword({
    required String email,
  });

  /// Logout
  Future<Either<AuthFailure, void>> logout();

  /// Verifica se há usuário logado
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser();
}

