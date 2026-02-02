part of 'profile_bloc.dart';

/// Eventos do ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar o perfil do usuário
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({this.force = false});

  final bool force;

  @override
  List<Object?> get props => [force];
}

/// Evento para atualizar o perfil do usuário
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

/// Evento para fazer upload de foto de perfil
class ProfilePictureUploadRequested extends ProfileEvent {
  const ProfilePictureUploadRequested(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Evento para fazer upload de banner
class ProfileBannerUploadRequested extends ProfileEvent {
  const ProfileBannerUploadRequested(this.imagePath);
  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Evento para atualizar nome e bio
class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
    this.name,
    this.bio,
  });
  final String? name;
  final String? bio;

  @override
  List<Object?> get props => [name, bio];
}
