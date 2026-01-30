import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/auth/domain/usecases/forgot_password_usecase.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

/// BLoC responsável pela lógica de recuperação de senha
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({
    required this.forgotPasswordUseCase,
  }) : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }
  final ForgotPasswordUseCase forgotPasswordUseCase;

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(
      email: event.email,
      status: ForgotPasswordStatus.initial,
      clearError: true,
    ),);
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading, clearError: true));

    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: state.email),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: failure.message,
      ),),
      (_) => emit(state.copyWith(
        status: ForgotPasswordStatus.success,
      ),),
    );
  }
}



