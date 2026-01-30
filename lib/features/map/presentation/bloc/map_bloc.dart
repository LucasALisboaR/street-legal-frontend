import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/data/services/mapbox_navigation_service.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_event.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_state.dart';
import 'package:geolocator/geolocator.dart';

/// BLoC responsável por gerenciar o estado do mapa
/// 
/// OTIMIZAÇÕES IMPLEMENTADAS:
/// - Throttle no stream de localização: não processa mais que 1 update/300ms
/// - Throttle no NavigationProgressUpdated: máximo 1 cálculo/500ms
/// - Stream de localização com accuracy bestForNavigation e distanceFilter 2m
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required LocationService locationService,
    required MapboxNavigationService navigationService,
  })  : _locationService = locationService,
        _navigationService = navigationService,
        super(MapState.initial()) {
    on<MapInitialized>(_onMapInitialized);
    on<UserPositionUpdated>(_onUserPositionUpdated);
    on<MapModeToggled>(_onMapModeToggled);
    on<NavigationStarted>(_onNavigationStarted);
    on<NavigationStopped>(_onNavigationStopped);
    on<NavigationProgressUpdated>(_onNavigationProgressUpdated);
    on<RouteRecalculationRequested>(_onRouteRecalculationRequested);
    on<CameraCenteredOnUser>(_onCameraCenteredOnUser);
    on<CameraZoomChanged>(_onCameraZoomChanged);
    on<DestinationSelected>(_onDestinationSelected);
    on<DestinationCleared>(_onDestinationCleared);
    on<LocationErrorOccurred>(_onLocationErrorOccurred);
  }

  final LocationService _locationService;
  final MapboxNavigationService _navigationService;
  StreamSubscription<Position>? _locationSubscription;

  /// Timer para verificar se o usuário está fora da rota
  Timer? _offRouteCheckTimer;

  /// Distância máxima da rota antes de recalcular (metros)
  static const double _offRouteThreshold = 50.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // THROTTLE: Controle de frequência de atualizações
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Última vez que processamos uma atualização de posição
  DateTime _lastPositionUpdate = DateTime.now();
  
  /// Última vez que processamos progresso de navegação
  DateTime _lastProgressUpdate = DateTime.now();
  
  /// Intervalo mínimo entre atualizações de posição (ms)
  static const int _positionThrottleMs = 300;
  
  /// Intervalo mínimo entre cálculos de progresso de navegação (ms)
  static const int _progressThrottleMs = 500;

  /// Inicialização do mapa
  Future<void> _onMapInitialized(
    MapInitialized event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoadingLocation: true, clearLocationError: true));

    // Verifica permissões
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) {
      emit(state.copyWith(
        isLoadingLocation: false,
        locationError: 'Permissão de localização negada. Por favor, ative nas configurações.',
      ));
      return;
    }

    // Obtém localização inicial
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      emit(state.copyWith(
        isLoadingLocation: false,
        locationError: 'Não foi possível obter a localização. Verifique se o GPS está ativado.',
      ));
      return;
    }

    emit(state.copyWith(
      isLoadingLocation: false,
      userPosition: MapPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
      userHeading: position.heading.isFinite ? position.heading : 0.0,
    ));

    // Inicia o stream de localização
    _startLocationStream();
  }

  /// Inicia o monitoramento contínuo da localização
  /// 
  /// OTIMIZAÇÃO: Stream configurado com:
  /// - accuracy: bestForNavigation (máxima precisão)
  /// - distanceFilter: 2 metros (fluidez sem spam)
  void _startLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService
        .getPositionStream(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2, // Atualiza a cada 2 metros para movimento suave
        )
        .listen(
          (position) {
            add(UserPositionUpdated(
              position: MapPoint(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
              heading: position.heading.isFinite ? position.heading : state.userHeading,
            ));
          },
          onError: (error) {
            add(const LocationErrorOccurred(
              message: 'Erro ao monitorar localização',
            ));
          },
        );
  }

  /// Atualiza a posição do usuário
  /// 
  /// OTIMIZAÇÃO: Throttle de 300ms para evitar processamento excessivo
  void _onUserPositionUpdated(
    UserPositionUpdated event,
    Emitter<MapState> emit,
  ) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastPositionUpdate).inMilliseconds;

    // Throttle: ignora se passou menos de 300ms desde o último update
    if (elapsed < _positionThrottleMs) {
      return;
    }
    _lastPositionUpdate = now;

    emit(state.copyWith(
      userPosition: event.position,
      userHeading: event.heading,
      clearLocationError: true,
    ));

    // Se estiver navegando, atualiza o progresso (também com throttle)
    if (state.isNavigating) {
      add(NavigationProgressUpdated(currentPosition: event.position));
    }
  }

  /// Alterna entre modo Normal e Drive
  void _onMapModeToggled(
    MapModeToggled event,
    Emitter<MapState> emit,
  ) {
    if (state.mode == MapMode.normal) {
      // Só pode ir para modo Drive se tiver destino
      if (state.hasDestination && state.userPosition != null) {
        add(NavigationStarted(destination: state.selectedDestination!));
      }
    } else {
      // Volta para modo Normal
      add(const NavigationStopped());
    }
  }

  /// Inicia a navegação
  Future<void> _onNavigationStarted(
    NavigationStarted event,
    Emitter<MapState> emit,
  ) async {
    if (state.userPosition == null) return;

    emit(state.copyWith(
      isCalculatingRoute: true,
      selectedDestination: event.destination,
    ));

    // Calcula a rota
    final route = await _navigationService.getRoute(
      origin: state.userPosition!,
      destination: event.destination.point,
    );

    if (route == null) {
      emit(state.copyWith(
        isCalculatingRoute: false,
        locationError: 'Não foi possível calcular a rota. Tente novamente.',
      ));
      return;
    }

    // Inicia a navegação
    emit(state.copyWith(
      mode: MapMode.drive,
      isCalculatingRoute: false,
      activeRoute: route,
      currentZoom: 17.0, // Zoom mais próximo durante navegação
      navigationState: NavigationState(
        route: route,
        currentPosition: state.userPosition!,
        currentStepIndex: 0,
        distanceToNextStep: route.instructions.isNotEmpty
            ? route.instructions.first.distance
            : 0,
        isOffRoute: false,
      ),
    ));

    // Inicia verificação periódica de desvio de rota
    _startOffRouteCheck();
  }

  /// Para a navegação
  void _onNavigationStopped(
    NavigationStopped event,
    Emitter<MapState> emit,
  ) {
    _stopOffRouteCheck();

    emit(state.copyWith(
      mode: MapMode.normal,
      currentZoom: 15.0,
      clearActiveRoute: true,
      clearNavigationState: true,
      clearSelectedDestination: true,
    ));
  }

  /// Atualiza o progresso da navegação
  /// 
  /// OTIMIZAÇÃO: Throttle de 500ms para evitar cálculos pesados frequentes
  void _onNavigationProgressUpdated(
    NavigationProgressUpdated event,
    Emitter<MapState> emit,
  ) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastProgressUpdate).inMilliseconds;

    // Throttle: ignora se passou menos de 500ms desde o último cálculo
    if (elapsed < _progressThrottleMs) {
      return;
    }
    _lastProgressUpdate = now;

    if (state.activeRoute == null || state.navigationState == null) return;

    final route = state.activeRoute!;
    final currentNav = state.navigationState!;

    // Verifica se está fora da rota
    final isOffRoute = _navigationService.isOffRoute(
      currentPosition: event.currentPosition,
      routeCoordinates: route.coordinates,
      tolerance: _offRouteThreshold,
    );

    if (isOffRoute && !currentNav.isOffRoute) {
      // Acabou de sair da rota - solicita recálculo
      add(const RouteRecalculationRequested());
      return;
    }

    // Encontra o segmento atual na rota
    final segmentIndex = _navigationService.findNearestSegmentIndex(
      currentPosition: event.currentPosition,
      routeCoordinates: route.coordinates,
    );

    // Calcula qual instrução corresponde ao segmento atual
    int stepIndex = 0;
    double accumulatedDistance = 0;
    for (int i = 0; i < route.instructions.length; i++) {
      accumulatedDistance += route.instructions[i].distance;
      if (segmentIndex < accumulatedDistance / 10) {
        // Aproximação
        stepIndex = i;
        break;
      }
      stepIndex = i;
    }

    // Calcula distância até próxima manobra
    double distanceToNext = 0;
    if (stepIndex < route.instructions.length) {
      final nextStepCoord = stepIndex + 1 < route.coordinates.length
          ? route.coordinates[stepIndex + 1]
          : route.coordinates.last;
      distanceToNext = _navigationService.calculateDistanceToNextStep(
        currentPosition: event.currentPosition,
        nextStepPosition: nextStepCoord,
      );
    }

    emit(state.copyWith(
      navigationState: NavigationState(
        route: route,
        currentPosition: event.currentPosition,
        currentStepIndex: stepIndex,
        distanceToNextStep: distanceToNext,
        isOffRoute: isOffRoute,
      ),
    ));
  }

  /// Recalcula a rota quando o usuário sai do caminho
  Future<void> _onRouteRecalculationRequested(
    RouteRecalculationRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.selectedDestination == null || state.userPosition == null) return;

    emit(state.copyWith(isCalculatingRoute: true));

    final newRoute = await _navigationService.recalculateRoute(
      currentPosition: state.userPosition!,
      destination: state.selectedDestination!.point,
    );

    if (newRoute == null) {
      emit(state.copyWith(
        isCalculatingRoute: false,
        locationError: 'Não foi possível recalcular a rota.',
      ));
      return;
    }

    emit(state.copyWith(
      isCalculatingRoute: false,
      activeRoute: newRoute,
      navigationState: NavigationState(
        route: newRoute,
        currentPosition: state.userPosition!,
        currentStepIndex: 0,
        distanceToNextStep: newRoute.instructions.isNotEmpty
            ? newRoute.instructions.first.distance
            : 0,
        isOffRoute: false,
      ),
    ));
  }

  /// Centraliza a câmera no usuário
  void _onCameraCenteredOnUser(
    CameraCenteredOnUser event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(isFollowingUser: true));
  }

  /// Altera o zoom da câmera
  void _onCameraZoomChanged(
    CameraZoomChanged event,
    Emitter<MapState> emit,
  ) {
    final currentZoom = state.currentZoom;
    final newZoom = event.zoomIn
        ? (currentZoom + 1).clamp(5.0, 20.0)
        : (currentZoom - 1).clamp(5.0, 20.0);

    emit(state.copyWith(
      currentZoom: newZoom,
      isFollowingUser: false, // Desativa follow ao interagir manualmente
    ));
  }

  /// Seleciona um destino
  void _onDestinationSelected(
    DestinationSelected event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(selectedDestination: event.destination));
  }

  /// Limpa o destino selecionado
  void _onDestinationCleared(
    DestinationCleared event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(clearSelectedDestination: true));
  }

  /// Trata erro de localização
  void _onLocationErrorOccurred(
    LocationErrorOccurred event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(locationError: event.message));
  }

  /// Inicia verificação periódica de desvio de rota
  void _startOffRouteCheck() {
    _offRouteCheckTimer?.cancel();
    _offRouteCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (state.isNavigating && state.userPosition != null) {
          add(NavigationProgressUpdated(currentPosition: state.userPosition!));
        }
      },
    );
  }

  /// Para verificação de desvio de rota
  void _stopOffRouteCheck() {
    _offRouteCheckTimer?.cancel();
    _offRouteCheckTimer = null;
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _stopOffRouteCheck();
    return super.close();
  }
}
