part of 'profile_bloc.dart';

/// Status do perfil
enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
  uploadingPicture,
  uploadingBanner,
  updatingProfile,
}

/// Estado do ProfileBloc
class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.avatarCacheBuster = 0,
    this.bannerCacheBuster = 0,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserProfileModel? profile;
  final int avatarCacheBuster;
  final int bannerCacheBuster;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileModel? profile,
    int? avatarCacheBuster,
    int? bannerCacheBuster,
    String? errorMessage,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      avatarCacheBuster: avatarCacheBuster ?? this.avatarCacheBuster,
      bannerCacheBuster: bannerCacheBuster ?? this.bannerCacheBuster,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        avatarCacheBuster,
        bannerCacheBuster,
        errorMessage,
      ];
}
