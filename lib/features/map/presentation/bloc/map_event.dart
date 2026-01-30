import 'package:equatable/equatable.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';

/// Eventos do MapBloc
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa o mapa e carrega a localização do usuário
class MapInitialized extends MapEvent {
  const MapInitialized();
}

/// Atualiza a posição do usuário (recebida do GPS)
class UserPositionUpdated extends MapEvent {
  const UserPositionUpdated({
    required this.position,
    required this.heading,
  });

  final MapPoint position;
  final double heading;

  @override
  List<Object?> get props => [position, heading];
}

/// Alterna entre modo Normal e modo Drive
class MapModeToggled extends MapEvent {
  const MapModeToggled();
}

/// Inicia a navegação para um destino
class NavigationStarted extends MapEvent {
  const NavigationStarted({
    required this.destination,
  });

  final NavigationDestination destination;

  @override
  List<Object?> get props => [destination];
}

/// Para a navegação ativa
class NavigationStopped extends MapEvent {
  const NavigationStopped();
}

/// Atualiza o estado da navegação (posição na rota)
class NavigationProgressUpdated extends MapEvent {
  const NavigationProgressUpdated({
    required this.currentPosition,
  });

  final MapPoint currentPosition;

  @override
  List<Object?> get props => [currentPosition];
}

/// Recalcula a rota (quando o usuário sai do caminho)
class RouteRecalculationRequested extends MapEvent {
  const RouteRecalculationRequested();
}

/// Centraliza a câmera na posição do usuário
class CameraCenteredOnUser extends MapEvent {
  const CameraCenteredOnUser();
}

/// Atualiza o zoom da câmera
class CameraZoomChanged extends MapEvent {
  const CameraZoomChanged({
    required this.zoomIn,
  });

  final bool zoomIn;

  @override
  List<Object?> get props => [zoomIn];
}

/// Define um destino para navegação (usado para busca)
class DestinationSelected extends MapEvent {
  const DestinationSelected({
    required this.destination,
  });

  final NavigationDestination destination;

  @override
  List<Object?> get props => [destination];
}

/// Limpa o destino selecionado
class DestinationCleared extends MapEvent {
  const DestinationCleared();
}

/// Erro de localização
class LocationErrorOccurred extends MapEvent {
  const LocationErrorOccurred({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

