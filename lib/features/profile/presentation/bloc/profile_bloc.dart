import 'dart:io';
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
    on<ProfilePictureUploadRequested>(_onPictureUploadRequested);
    on<ProfileBannerUploadRequested>(_onBannerUploadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
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

  Future<void> _onPictureUploadRequested(
    ProfilePictureUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Usuário não encontrado',
      ));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.uploadingPicture));

    final imageFile = File(event.imagePath);
    if (!await imageFile.exists()) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Arquivo de imagem não encontrado',
      ));
      return;
    }

    final uploadResult = await usersService.uploadPicture(userId, imageFile);

    await uploadResult.fold(
      (error) async => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.message,
      )),
      (_) async {
        // Após upload bem-sucedido, recarregar o perfil completo
        final profileResult = await usersService.getUserProfile(userId);
        profileResult.fold(
          (error) => emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error.message,
          )),
          (profile) => emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          )),
        );
      },
    );
  }

  Future<void> _onBannerUploadRequested(
    ProfileBannerUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Usuário não encontrado',
      ));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.uploadingBanner));

    final imageFile = File(event.imagePath);
    if (!await imageFile.exists()) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Arquivo de imagem não encontrado',
      ));
      return;
    }

    final uploadResult = await usersService.uploadBanner(userId, imageFile);

    await uploadResult.fold(
      (error) async => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.message,
      )),
      (_) async {
        // Após upload bem-sucedido, recarregar o perfil completo
        final profileResult = await usersService.getUserProfile(userId);
        profileResult.fold(
          (error) => emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error.message,
          )),
          (profile) => emit(state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
          )),
        );
      },
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Usuário não encontrado',
      ));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.updatingProfile));

    try {
      final updateResult = await usersService.updateProfile(
        userId: userId,
        name: event.name,
        bio: event.bio,
      );

      await updateResult.fold(
        (error) async {
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error.message.isNotEmpty 
                ? error.message 
                : 'Erro ao atualizar perfil',
          ));
        },
        (_) async {
          // Sempre fazer GET após PATCH bem-sucedido para garantir dados completos
          // Aguardar um pouco para garantir que o backend processou a atualização
          await Future<void>.delayed(const Duration(milliseconds: 300));
          
          try {
            final profileResult = await usersService.getUserProfile(userId);
            profileResult.fold(
              (error) {
                emit(state.copyWith(
                  status: ProfileStatus.failure,
                  errorMessage: error.message.isNotEmpty 
                      ? error.message 
                      : 'Erro ao carregar perfil atualizado',
                ));
              },
              (profile) {
                emit(state.copyWith(
                  status: ProfileStatus.success,
                  profile: profile,
                  errorMessage: null, // Limpar qualquer erro anterior
                ));
              },
            );
          } catch (e) {
            emit(state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: 'Erro ao carregar perfil: ${e.toString()}',
            ));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Erro inesperado ao atualizar perfil: ${e.toString()}',
      ));
    }
  }
}

