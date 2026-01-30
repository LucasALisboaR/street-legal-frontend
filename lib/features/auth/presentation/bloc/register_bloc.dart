import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/auth/domain/entities/user_entity.dart';
import 'package:gearhead_br/features/auth/domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

/// BLoC responsável pela lógica de registro
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required this.registerUseCase,
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

    final result = await registerUseCase(
      RegisterParams(
        email: state.email,
        password: state.password,
        displayName: state.name.isNotEmpty ? state.name : null,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: failure.message,
      ),),
      (user) => emit(state.copyWith(
        status: RegisterStatus.success,
        user: user,
      ),),
    );
  }
}

