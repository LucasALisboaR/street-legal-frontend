import 'package:equatable/equatable.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';

/// Modos de operação do mapa
enum MapMode {
  /// Modo normal - apenas visualização e tracking
  normal,

  /// Modo preview - rota carregada antes da navegação
  preview,

  /// Modo drive - navegação ativa com rota
  drive,
}

/// Estado do MapBloc
class MapState extends Equatable {
  const MapState({
    this.mode = MapMode.normal,
    this.userPosition,
    this.userHeading = 0.0,
    this.isLoadingLocation = true,
    this.locationError,
    this.selectedDestination,
    this.activeRoute,
    this.navigationState,
    this.isCalculatingRoute = false,
    this.isFollowingUser = true,
    this.currentZoom = 15.0,
    this.speedLimitKmh,
  });

  /// Modo atual do mapa (Normal ou Drive)
  final MapMode mode;

  /// Posição atual do usuário
  final MapPoint? userPosition;

  /// Direção do usuário em graus (0-360)
  final double userHeading;

  /// Indica se está carregando a localização inicial
  final bool isLoadingLocation;

  /// Mensagem de erro de localização (se houver)
  final String? locationError;

  /// Destino selecionado para navegação
  final NavigationDestination? selectedDestination;

  /// Rota ativa (quando em modo Drive)
  final NavigationRoute? activeRoute;

  /// Estado da navegação ativa
  final NavigationState? navigationState;

  /// Indica se está calculando uma rota
  final bool isCalculatingRoute;

  /// Indica se a câmera está seguindo o usuário
  final bool isFollowingUser;

  /// Nível de zoom atual
  final double currentZoom;

  /// Limite de velocidade atual (km/h) durante navegação
  final double? speedLimitKmh;

  @override
  List<Object?> get props => [
        mode,
        userPosition,
        userHeading,
        isLoadingLocation,
        locationError,
        selectedDestination,
        activeRoute,
        navigationState,
        isCalculatingRoute,
        isFollowingUser,
        currentZoom,
        speedLimitKmh,
      ];

  /// Cria uma cópia do estado com valores alterados
  MapState copyWith({
    MapMode? mode,
    MapPoint? userPosition,
    double? userHeading,
    bool? isLoadingLocation,
    String? locationError,
    NavigationDestination? selectedDestination,
    NavigationRoute? activeRoute,
    NavigationState? navigationState,
    bool? isCalculatingRoute,
    bool? isFollowingUser,
    double? currentZoom,
    double? speedLimitKmh,
    bool clearLocationError = false,
    bool clearSelectedDestination = false,
    bool clearActiveRoute = false,
    bool clearNavigationState = false,
    bool clearSpeedLimit = false,
  }) {
    return MapState(
      mode: mode ?? this.mode,
      userPosition: userPosition ?? this.userPosition,
      userHeading: userHeading ?? this.userHeading,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: clearLocationError ? null : (locationError ?? this.locationError),
      selectedDestination: clearSelectedDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      activeRoute: clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      navigationState: clearNavigationState
          ? null
          : (navigationState ?? this.navigationState),
      isCalculatingRoute: isCalculatingRoute ?? this.isCalculatingRoute,
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      currentZoom: currentZoom ?? this.currentZoom,
      speedLimitKmh: clearSpeedLimit ? null : (speedLimitKmh ?? this.speedLimitKmh),
    );
  }

  /// Estado inicial do mapa
  factory MapState.initial() => const MapState();

  /// Verifica se está em navegação ativa
  bool get isNavigating => mode == MapMode.drive && activeRoute != null;

  /// Verifica se está em preview de rota
  bool get isPreviewing => mode == MapMode.preview && activeRoute != null;

  /// Verifica se há um destino selecionado
  bool get hasDestination => selectedDestination != null;

  /// Verifica se o usuário está fora da rota
  bool get isOffRoute => navigationState?.isOffRoute ?? false;

  /// Zoom adequado para o modo atual
  double get appropriateZoom {
    if (mode == MapMode.drive) {
      return 17.0; // Mais perto durante navegação
    }
    return 15.0; // Padrão para modo normal
  }

  /// Tilt (inclinação) adequado para o modo atual
  double get appropriateTilt {
    if (mode == MapMode.drive) {
      return 60.0; // Visão 3D durante navegação
    }
    return 0.0; // Visão de cima no modo normal
  }
}
