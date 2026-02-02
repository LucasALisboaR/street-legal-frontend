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

    final result = await usersService.getUserProfile(
      userId,
      force: event.force,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.message,
      )),
      (profile) => emit(_mergeProfileUpdate(
        profile,
        status: ProfileStatus.success,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.status == ProfileStatus.loading) return;
    add(const ProfileLoadRequested(force: true));
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
      (profile) async {
        emit(_mergeProfileUpdate(
          profile,
          status: ProfileStatus.success,
          bumpAvatarCache: true,
        ));
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
      (profile) async {
        emit(_mergeProfileUpdate(
          profile,
          status: ProfileStatus.success,
          bumpBannerCache: true,
        ));
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
        (profile) async {
          final updatedProfile =
              profile ?? usersService.getCachedProfile() ?? state.profile;
          if (updatedProfile == null) {
            emit(state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: 'Erro ao carregar perfil atualizado',
            ));
            return;
          }

          emit(_mergeProfileUpdate(
            updatedProfile,
            status: ProfileStatus.success,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: 'Erro inesperado ao atualizar perfil: ${e.toString()}',
      ));
    }
  }

  ProfileState _mergeProfileUpdate(
    UserProfileModel profile, {
    required ProfileStatus status,
    bool bumpAvatarCache = false,
    bool bumpBannerCache = false,
  }) {
    final shouldBumpAvatar =
        bumpAvatarCache || state.profile?.avatarUrl != profile.avatarUrl;
    final shouldBumpBanner =
        bumpBannerCache || state.profile?.bannerUrl != profile.bannerUrl;

    return state.copyWith(
      status: status,
      profile: profile,
      avatarCacheBuster:
          shouldBumpAvatar ? DateTime.now().millisecondsSinceEpoch : null,
      bannerCacheBuster:
          shouldBumpBanner ? DateTime.now().millisecondsSinceEpoch : null,
      clearError: true,
    );
  }
}
