part of 'forgot_password_bloc.dart';

/// Eventos do BLoC de Recuperação de Senha
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// E-mail foi alterado
class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  const ForgotPasswordEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Formulário foi submetido
class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordSubmitted();
}



