import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/profile/data/models/user_profile_model.dart';
import 'package:gearhead_br/features/users/data/services/users_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC responsável pela lógica do perfil do usuário
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.usersService,
    required this.sessionStorage,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
  }

  final UsersService usersService;
  final SessionStorage sessionStorage;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.status == ProfileStatus.loading) return;

    emit(state.copyWith(status: ProfileStatus.loading));

    // Obter ID do usuário do storage
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Usuário não encontrado',
      ));
      return;
    }

    final result = await usersService.getUserProfile(userId);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.message,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Resetar estado e recarregar
    emit(const ProfileState());
    add(const ProfileLoadRequested());
  }
}

