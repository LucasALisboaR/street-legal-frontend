import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

/// BLoC responsável pela lógica de login
class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc({
    required this.loginUseCase,
  }) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
  }
  final LoginUseCase loginUseCase;

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      email: event.email,
      status: LoginStatus.initial,
      clearError: true,
    ),);
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      status: LoginStatus.initial,
      clearError: true,
    ),);
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ),);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: LoginStatus.loading, clearError: true));

    final result = await loginUseCase(
      LoginParams(email: state.email, password: state.password),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      ),),
      (user) => emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      ),),
    );
  }
}

