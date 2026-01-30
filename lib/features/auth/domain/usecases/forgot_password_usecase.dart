import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';

/// Parâmetros para recuperação de senha
class ForgotPasswordParams {
  const ForgotPasswordParams({
    required this.email,
  });
  final String email;
}

/// Use case para recuperação de senha
class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<AuthFailure, void>> call(ForgotPasswordParams params) async {
    return _repository.forgotPassword(email: params.email);
  }
}



