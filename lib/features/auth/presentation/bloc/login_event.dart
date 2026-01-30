part of 'login_bloc.dart';

/// Eventos do BLoC de Login
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// E-mail foi alterado
class LoginEmailChanged extends LoginEvent {

  const LoginEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Senha foi alterada
class LoginPasswordChanged extends LoginEvent {

  const LoginPasswordChanged(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

/// Toggle visibilidade da senha
class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

/// Formulário foi submetido
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

