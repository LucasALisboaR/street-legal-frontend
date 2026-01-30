part of 'register_bloc.dart';

/// Eventos do BLoC de Registro
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Nome foi alterado
class RegisterNameChanged extends RegisterEvent {
  const RegisterNameChanged(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

/// E-mail foi alterado
class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Senha foi alterada
class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

/// Confirmação de senha foi alterada
class RegisterConfirmPasswordChanged extends RegisterEvent {
  const RegisterConfirmPasswordChanged(this.confirmPassword);
  final String confirmPassword;

  @override
  List<Object?> get props => [confirmPassword];
}

/// Toggle visibilidade da senha
class RegisterPasswordVisibilityToggled extends RegisterEvent {
  const RegisterPasswordVisibilityToggled();
}

/// Toggle visibilidade da confirmação de senha
class RegisterConfirmPasswordVisibilityToggled extends RegisterEvent {
  const RegisterConfirmPasswordVisibilityToggled();
}

/// Termos de uso foram aceitos/recusados
class RegisterTermsAcceptedChanged extends RegisterEvent {
  const RegisterTermsAcceptedChanged(this.accepted);
  final bool accepted;

  @override
  List<Object?> get props => [accepted];
}

/// Formulário foi submetido
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

