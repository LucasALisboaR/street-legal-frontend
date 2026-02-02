part of 'login_bloc.dart';

/// Status do formulário de login
enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado do BLoC de Login
class LoginState extends Equatable {

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
    this.backendUser,
  });
  final String email;
  final String password;
  final bool isPasswordVisible;
  final LoginStatus status;
  final String? errorMessage;
  final UserEntity? user;
  final UserModel? backendUser;

  /// Verifica se o e-mail é válido
  bool get isEmailValid {
    if (email.isEmpty) return true;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Verifica se a senha é válida (mínimo 6 caracteres)
  bool get isPasswordValid {
    if (password.isEmpty) return true;
    return password.length >= 6;
  }

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        isEmailValid &&
        isPasswordValid &&
        status != LoginStatus.loading;
  }

  /// Mensagem de erro do e-mail
  String? get emailError {
    if (email.isEmpty || isEmailValid) return null;
    return 'Digite um e-mail válido';
  }

  /// Mensagem de erro da senha
  String? get passwordError {
    if (password.isEmpty || isPasswordValid) return null;
    return 'A senha deve ter no mínimo 6 caracteres';
  }

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    LoginStatus? status,
    String? errorMessage,
    UserEntity? user,
    UserModel? backendUser,
    bool clearError = false,
    bool clearUser = false,
    bool clearBackendUser = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
      backendUser:
          clearBackendUser ? null : (backendUser ?? this.backendUser),
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordVisible,
        status,
        errorMessage,
        user,
        backendUser,
      ];
}
