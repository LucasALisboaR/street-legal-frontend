import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';

/// Implementação do repositório de autenticação com Firebase Auth
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);
  
  final FirebaseAuth _firebaseAuth;

  /// Converte FirebaseAuthException para AuthFailure
  AuthFailure _mapFirebaseException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      case 'user-disabled':
        return const UnknownFailure('Esta conta foi desabilitada');
      case 'too-many-requests':
        return const UnknownFailure('Muitas tentativas. Tente novamente mais tarde');
      case 'operation-not-allowed':
        return const UnknownFailure('Operação não permitida');
      default:
        return UnknownFailure(exception.message ?? 'Erro ao autenticar');
    }
  }

  /// Converte User do Firebase para UserEntity
  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<Either<AuthFailure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        return const Left(InvalidCredentialsFailure());
      }
      
      return Right(_mapFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return const Left(NetworkFailure());
    }
  }

  // Login social removido temporariamente
  // @override
  // Future<Either<AuthFailure, UserEntity>> loginWithSocial({
  //   required SocialAuthType type,
  // }) async {
  //   return const Left(UnknownFailure('Login social não disponível no momento'));
  // }

  @override
  Future<Either<AuthFailure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        return const Left(UnknownFailure('Erro ao criar usuário'));
      }
      
      // Atualizar display name se fornecido
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser != null) {
          return Right(_mapFirebaseUser(updatedUser));
        }
      }
      
      return Right(_mapFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<AuthFailure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Firebase não revela se o email existe por segurança
        // Retornamos sucesso mesmo se o usuário não existir
        return const Right(null);
      }
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(UnknownFailure('Erro ao fazer logout'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Right(null);
      }
      return Right(_mapFirebaseUser(user));
    } catch (e) {
      return const Left(UnknownFailure('Erro ao obter usuário atual'));
    }
  }
}

