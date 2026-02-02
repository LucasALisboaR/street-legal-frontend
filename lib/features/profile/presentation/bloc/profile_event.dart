part of 'profile_bloc.dart';

/// Eventos do ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar o perfil do usuário
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Evento para atualizar o perfil do usuário
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

