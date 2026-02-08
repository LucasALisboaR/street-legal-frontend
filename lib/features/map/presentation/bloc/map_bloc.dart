import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/map/data/services/heading_service.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/data/services/mapbox_navigation_service.dart';
import 'package:gearhead_br/features/map/domain/entities/map_user_entity.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';
import 'package:gearhead_br/features/map/domain/utils/geo_utils.dart';
import 'package:gearhead_br/features/map/domain/utils/navigation_metrics.dart';
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
    required HeadingService headingService,
    required MapboxNavigationService navigationService,
    required MapRepository mapRepository,
  })  : _locationService = locationService,
        _headingService = headingService,
        _navigationService = navigationService,
        _mapRepository = mapRepository,
        super(MapState.initial()) {
    on<MapInitialized>(_onMapInitialized);
    on<UserPositionUpdated>(_onUserPositionUpdated);
    on<UserHeadingUpdated>(_onUserHeadingUpdated);
    on<MapModeToggled>(_onMapModeToggled);
    on<NavigationStarted>(_onNavigationStarted);
    on<NavigationStopped>(_onNavigationStopped);
    on<NavigationProgressUpdated>(_onNavigationProgressUpdated);
    on<RouteRecalculationRequested>(_onRouteRecalculationRequested);
    on<CameraCenteredOnUser>(_onCameraCenteredOnUser);
    on<CameraFollowDisabled>(_onCameraFollowDisabled);
    on<CameraZoomChanged>(_onCameraZoomChanged);
    on<DestinationSelected>(_onDestinationSelected);
    on<DestinationCleared>(_onDestinationCleared);
    on<RoutePreviewCancelled>(_onRoutePreviewCancelled);
    on<LocationErrorOccurred>(_onLocationErrorOccurred);
    on<NearbyPointsRequested>(_onNearbyPointsRequested);
  }

  final LocationService _locationService;
  final HeadingService _headingService;
  final MapboxNavigationService _navigationService;
  final MapRepository _mapRepository;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<double>? _deviceHeadingSubscription;

  final HeadingSmoother _headingSmoother = HeadingSmoother();
  DateTime? _lastDeviceHeadingAt;
  double? _lastDeviceHeadingValue;

  /// Timer para verificar se o usuário está fora da rota
  Timer? _offRouteCheckTimer;

  /// Distância máxima da rota antes de recalcular (metros)
  static const double _offRouteThreshold = 50.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // THROTTLE: Controle de frequência de atualizações
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Última vez que processamos uma atualização de posição
  DateTime _lastPositionUpdate = DateTime.now();

  /// Última vez que sincronizamos a localização com o backend
  DateTime _lastLocationSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
  
  /// Última vez que processamos progresso de navegação
  DateTime _lastProgressUpdate = DateTime.now();
  
  /// Intervalo mínimo entre atualizações de posição (ms)
  static const int _positionThrottleMs = 300;

  /// Intervalo mínimo entre updates de heading (ms)
  static const int _headingThrottleMs = 120;

  /// Intervalo mínimo entre sincronizações de localização (ms)
  static const int _locationSyncThrottleMs = 5000;

  /// Tempo máximo para considerar heading do device como válido
  static const Duration _deviceHeadingTimeout = Duration(seconds: 2);
  
  /// Intervalo mínimo entre cálculos de progresso de navegação (ms)
  static const int _progressThrottleMs = 500;

  /// Distância mínima para recalcular usuários/eventos próximos (metros)
  static const double _nearbyRefreshThresholdMeters = 300.0;
  MapPoint? _lastNearbyAnchor;

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
      userHeading: normalizeHeading(position.heading.isFinite ? position.heading : 0.0),
      userHeadingSource: HeadingSource.gps,
      userSpeedKmh: speedToKmh(position.speed),
    ));

    // Inicia o stream de localização
    _startLocationStream();
    _startHeadingStream();

    // Reutiliza os mocks do repositório, ancorados na posição real do usuário.
    add(const NearbyPointsRequested(force: true));
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
              speedMetersPerSecond: position.speed.isFinite ? position.speed : 0.0,
            ));
          },
          onError: (error) {
            add(const LocationErrorOccurred(
              message: 'Erro ao monitorar localização',
            ));
          },
        );
  }

  /// Inicia o monitoramento do heading do device (bússola)
  void _startHeadingStream() {
    _deviceHeadingSubscription?.cancel();
    _deviceHeadingSubscription = _headingService.getHeadingStream().listen(
      (heading) {
        final now = DateTime.now();
        if (_lastDeviceHeadingAt != null &&
            now.difference(_lastDeviceHeadingAt!).inMilliseconds < _headingThrottleMs) {
          return;
        }
        _lastDeviceHeadingAt = now;
        add(UserHeadingUpdated(heading: heading));
      },
      onError: (_) {},
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

    final headingToUse = _resolveHeading(event.heading);
    emit(state.copyWith(
      userPosition: event.position,
      userHeading: headingToUse,
      userHeadingSource: _resolveHeadingSource(),
      userSpeedKmh: speedToKmh(event.speedMetersPerSecond),
      clearLocationError: true,
    ));

    // Atualiza pontos próximos apenas quando o usuário se desloca o suficiente.
    add(const NearbyPointsRequested());

    // Se estiver navegando, atualiza o progresso (também com throttle)
    if (state.isNavigating) {
      add(NavigationProgressUpdated(currentPosition: event.position));
    }

    _syncUserLocation(event.position);
  }

  void _syncUserLocation(MapPoint position) {
    final now = DateTime.now();
    if (now.difference(_lastLocationSyncAt).inMilliseconds <
        _locationSyncThrottleMs) {
      return;
    }
    _lastLocationSyncAt = now;

    _mapRepository.updateUserLocation(
      LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        address: null,
        timestamp: now,
      ),
    );
  }

  void _onUserHeadingUpdated(
    UserHeadingUpdated event,
    Emitter<MapState> emit,
  ) {
    final smoothedHeading = _headingSmoother.update(event.heading);
    _lastDeviceHeadingValue = smoothedHeading;
    _lastDeviceHeadingAt = DateTime.now();

    emit(state.copyWith(
      userHeading: smoothedHeading,
      userHeadingSource: HeadingSource.device,
    ));
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

    final isPreviewRoute = state.mode == MapMode.preview &&
        state.activeRoute != null &&
        state.selectedDestination == event.destination;

    emit(state.copyWith(
      isCalculatingRoute: !isPreviewRoute,
      selectedDestination: event.destination,
    ));

    final NavigationRoute? route;

    if (isPreviewRoute) {
      route = state.activeRoute;
    } else {
      // Calcula a rota
      route = await _navigationService.getRoute(
        origin: state.userPosition!,
        destination: event.destination.point,
      );
    }

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
      currentZoom: 18.0, // Zoom mais próximo durante navegação (estilo Waze)
      isFollowingUser: true,
      speedLimitKmh: route.speedLimitsKmh.isNotEmpty ? route.speedLimitsKmh.first : null,
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
      isFollowingUser: true,
      clearSpeedLimit: true,
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

    // Limite de velocidade vem das annotations da Directions API (km/h).
    final speedLimit = route.speedLimitsKmh.isNotEmpty && segmentIndex < route.speedLimitsKmh.length
        ? route.speedLimitsKmh[segmentIndex]
        : null;

    emit(state.copyWith(
      navigationState: NavigationState(
        route: route,
        currentPosition: event.currentPosition,
        currentStepIndex: stepIndex,
        distanceToNextStep: distanceToNext,
        isOffRoute: isOffRoute,
      ),
      speedLimitKmh: speedLimit,
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
      speedLimitKmh:
          newRoute.speedLimitsKmh.isNotEmpty ? newRoute.speedLimitsKmh.first : null,
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

  /// Desativa o follow quando o usuário interage com o mapa
  /// 
  /// IMPORTANTE: No modo drive, o follow sempre permanece ativo
  void _onCameraFollowDisabled(
    CameraFollowDisabled event,
    Emitter<MapState> emit,
  ) {
    // No modo drive, não permite desativar o follow
    if (state.mode == MapMode.drive) return;
    
    if (!state.isFollowingUser) return;
    emit(state.copyWith(isFollowingUser: false));
  }

  /// Altera o zoom da câmera
  /// 
  /// IMPORTANTE: No modo drive, mantém o follow ativo
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
      // No modo drive, mantém o follow ativo; no modo normal, desativa
      isFollowingUser: state.mode == MapMode.drive ? true : false,
    ));
  }

  /// Seleciona um destino
  Future<void> _onDestinationSelected(
    DestinationSelected event,
    Emitter<MapState> emit,
  ) async {
    if (state.userPosition == null) {
      emit(state.copyWith(
        locationError: 'Localização indisponível para calcular rota.',
      ));
      return;
    }

    emit(state.copyWith(
      selectedDestination: event.destination,
      isCalculatingRoute: true,
      mode: MapMode.normal,
      clearActiveRoute: true,
      clearNavigationState: true,
      clearSpeedLimit: true,
    ));

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

    emit(state.copyWith(
      mode: MapMode.preview,
      isCalculatingRoute: false,
      activeRoute: route,
      isFollowingUser: false,
    ));
  }

  /// Limpa o destino selecionado
  void _onDestinationCleared(
    DestinationCleared event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      mode: MapMode.normal,
      isCalculatingRoute: false,
      isFollowingUser: true,
      clearSpeedLimit: true,
      clearActiveRoute: true,
      clearNavigationState: true,
      clearSelectedDestination: true,
    ));
  }

  /// Cancela o preview de rota e volta ao modo normal
  void _onRoutePreviewCancelled(
    RoutePreviewCancelled event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      mode: MapMode.normal,
      isCalculatingRoute: false,
      isFollowingUser: true,
      clearSpeedLimit: true,
      clearActiveRoute: true,
      clearNavigationState: true,
      clearSelectedDestination: true,
    ));
  }

  /// Trata erro de localização
  void _onLocationErrorOccurred(
    LocationErrorOccurred event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(locationError: event.message));
  }

  /// Busca usuários e eventos próximos de forma eficiente.
  Future<void> _onNearbyPointsRequested(
    NearbyPointsRequested event,
    Emitter<MapState> emit,
  ) async {
    final position = state.userPosition;
    if (position == null) return;

    if (!event.force && _lastNearbyAnchor != null) {
      final distance = haversineDistanceMeters(position, _lastNearbyAnchor!);
      if (distance < _nearbyRefreshThresholdMeters) {
        return;
      }
    }

    _lastNearbyAnchor = position;

    final meetupsResult = await _mapRepository.getNearbyMeetups(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusKm: 2,
    );

    final usersResult = await _mapRepository.getNearbyUsers(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusKm: 2,
    );

    final nextMeetups = meetupsResult.fold(
      (_) => state.nearbyMeetups,
      (meetups) => meetups,
    );

    final nextUsers = usersResult.fold(
      (_) => state.nearbyUsers,
      (users) => users.map(MapUserEntity.fromMap).toList(),
    );

    emit(state.copyWith(
      nearbyMeetups: nextMeetups,
      nearbyUsers: nextUsers,
    ));
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
    _deviceHeadingSubscription?.cancel();
    _stopOffRouteCheck();
    return super.close();
  }

  double _resolveHeading(double gpsHeading) {
    if (_isDeviceHeadingFresh && _lastDeviceHeadingValue != null) {
      return _lastDeviceHeadingValue!;
    }
    return normalizeHeading(gpsHeading);
  }

  HeadingSource _resolveHeadingSource() {
    return _isDeviceHeadingFresh ? HeadingSource.device : HeadingSource.gps;
  }

  bool get _isDeviceHeadingFresh {
    if (_lastDeviceHeadingAt == null) return false;
    return DateTime.now().difference(_lastDeviceHeadingAt!) <= _deviceHeadingTimeout;
  }
}
