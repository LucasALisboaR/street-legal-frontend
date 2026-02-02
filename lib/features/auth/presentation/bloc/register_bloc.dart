import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/usecases/register_usecase.dart';
import 'package:gearhead_br/features/users/data/services/users_service.dart';

part 'register_event.dart';
part 'register_state.dart';

/// BLoC responsável pela lógica de registro
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required this.registerUseCase,
    required this.usersService,
    required this.sessionStorage,
  }) : super(const RegisterState()) {
    on<RegisterNameChanged>(_onNameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<RegisterConfirmPasswordVisibilityToggled>(_onConfirmPasswordVisibilityToggled);
    on<RegisterTermsAcceptedChanged>(_onTermsAcceptedChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }
  final RegisterUseCase registerUseCase;
  final UsersService usersService;
  final SessionStorage sessionStorage;

  void _onNameChanged(
    RegisterNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      name: event.name,
      status: RegisterStatus.initial,
      clearError: true,
    ),);
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      email: event.email,
      status: RegisterStatus.initial,
      clearError: true,
    ),);
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      status: RegisterStatus.initial,
      clearError: true,
    ),);
  }

  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      status: RegisterStatus.initial,
      clearError: true,
    ),);
  }

  void _onPasswordVisibilityToggled(
    RegisterPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ),);
  }

  void _onConfirmPasswordVisibilityToggled(
    RegisterConfirmPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    ),);
  }

  void _onTermsAcceptedChanged(
    RegisterTermsAcceptedChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      termsAccepted: event.accepted,
    ),);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: RegisterStatus.loading, clearError: true));

    // 1. Registrar no Firebase Auth
    final result = await registerUseCase(
      RegisterParams(
        email: state.email,
        password: state.password,
        displayName: state.name.isNotEmpty ? state.name : null,
      ),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      )),
      (user) async {
        // 2. Após sucesso no Firebase, criar perfil no backend
        // O token será automaticamente enviado pelo AuthInterceptor
        final createUserResult = await usersService.createUser({
          'name': state.name.isNotEmpty ? state.name : user.displayName ?? '',
          'email': state.email,
        });

        await createUserResult.fold(
          (error) async => emit(state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: error.message,
          )),
          (backendUser) async {
            // 3. Salvar usuário do backend no storage
            await sessionStorage.saveUser(backendUser);
            emit(state.copyWith(
              status: RegisterStatus.success,
              user: user,
            ));
          },
        );
      },
    );
  }
}

