part of 'forgot_password_bloc.dart';

/// Status do formulário de recuperação de senha
enum ForgotPasswordStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado do BLoC de Recuperação de Senha
class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });
  final String email;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  /// Verifica se o e-mail é válido
  bool get isEmailValid {
    if (email.isEmpty) return true;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit {
    return email.isNotEmpty &&
        isEmailValid &&
        status != ForgotPasswordStatus.loading;
  }

  /// Mensagem de erro do e-mail
  String? get emailError {
    if (email.isEmpty || isEmailValid) return null;
    return 'Digite um e-mail válido';
  }

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        email,
        status,
        errorMessage,
      ];
}



