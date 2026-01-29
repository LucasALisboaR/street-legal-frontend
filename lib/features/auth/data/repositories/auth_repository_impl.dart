import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';

/// Implementação mock do repositório de autenticação
/// TODO: Substituir por implementação real com Firebase/Backend
class AuthRepositoryImpl implements AuthRepository {
  
  @override
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock: aceita qualquer e-mail válido com senha "123456"
    if (password == '123456') {
      return Right(UserEntity(
        id: 'mock-user-id',
        email: email,
        displayName: 'Piloto GEARHEAD',
        photoUrl: null,
        createdAt: DateTime.now(),
      ));
    }
    
    return const Left(InvalidCredentialsFailure());
  }

  @override
  Future<Either<AuthFailure, UserEntity>> loginWithSocial({
    required SocialAuthType type,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock: sempre retorna sucesso
    final providerName = switch (type) {
      SocialAuthType.google => 'Google',
      SocialAuthType.apple => 'Apple',
      SocialAuthType.facebook => 'Facebook',
    };
    
    return Right(UserEntity(
      id: 'social-user-${type.name}',
      email: 'user@$providerName.com'.toLowerCase(),
      displayName: 'Piloto $providerName',
      photoUrl: null,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<AuthFailure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock: sempre retorna sucesso
    return Right(UserEntity(
      id: 'new-user-id',
      email: email,
      displayName: displayName ?? 'Novo Piloto',
      photoUrl: null,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<AuthFailure, void>> forgotPassword({
    required String email,
  }) async {
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: sempre retorna sucesso
    return const Right(null);
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const Right(null);
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    // Mock: não há usuário logado inicialmente
    return const Right(null);
  }
}

