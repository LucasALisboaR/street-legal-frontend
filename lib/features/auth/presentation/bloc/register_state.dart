part of 'register_bloc.dart';

/// Status do formulário de registro
enum RegisterStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado do BLoC de Registro
class RegisterState extends Equatable {
  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.termsAccepted = false,
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.user,
  });
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool termsAccepted;
  final RegisterStatus status;
  final String? errorMessage;
  final UserEntity? user;

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

  /// Verifica se as senhas coincidem
  bool get doPasswordsMatch {
    if (password.isEmpty || confirmPassword.isEmpty) return true;
    return password == confirmPassword;
  }

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        isEmailValid &&
        isPasswordValid &&
        doPasswordsMatch &&
        termsAccepted &&
        status != RegisterStatus.loading;
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

  /// Mensagem de erro da confirmação de senha
  String? get confirmPasswordError {
    if (confirmPassword.isEmpty || doPasswordsMatch) return null;
    return 'As senhas não coincidem';
  }

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? termsAccepted,
    RegisterStatus? status,
    String? errorMessage,
    UserEntity? user,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        confirmPassword,
        isPasswordVisible,
        isConfirmPasswordVisible,
        termsAccepted,
        status,
        errorMessage,
        user,
      ];
}

