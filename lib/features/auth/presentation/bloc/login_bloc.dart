import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/usecases/login_usecase.dart';
import 'package:gearhead_br/features/users/data/models/user_model.dart';
import 'package:gearhead_br/features/users/data/services/users_service.dart';

part 'login_event.dart';
part 'login_state.dart';

/// BLoC responsável pela lógica de login
class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc({
    required this.loginUseCase,
    required this.usersService,
    required this.sessionStorage,
    required this.authService,
  }) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
  }
  final LoginUseCase loginUseCase;
  final UsersService usersService;
  final SessionStorage sessionStorage;
  final AuthService authService;

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

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      ),),
      (user) async {
        final syncResult = await usersService.sync();
        await syncResult.fold(
          (error) async {
            await authService.logout(redirectToLogin: false);
            emit(state.copyWith(
              status: LoginStatus.failure,
              errorMessage: error.message,
            ),);
          },
          (backendUser) async {
            await sessionStorage.saveUser(backendUser);
            emit(state.copyWith(
              status: LoginStatus.success,
              user: user,
              backendUser: backendUser,
            ),);
          },
        );
      },
    );
  }
}
