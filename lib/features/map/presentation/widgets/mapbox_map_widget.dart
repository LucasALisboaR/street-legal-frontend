import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_state.dart';

/// Widget encapsulado do Mapa Mapbox
/// 
/// OTIMIZAÇÕES IMPLEMENTADAS:
/// - Usa o "puck" nativo do Mapbox para mostrar localização (mais performático)
/// - Usa easeTo em vez de flyTo (mais leve para atualizações frequentes)
/// - Throttle na câmera: atualiza no máximo a cada 250ms
/// - Removido overlay Flutter que usava pixelForCoordinate (pesado)
class MapboxMapWidget extends StatefulWidget {
  const MapboxMapWidget({
    super.key,
    required this.mapState,
    required this.onMapCreated,
    this.onUserCameraInteraction,
  });

  final MapState mapState;
  final void Function(MapboxMap mapboxMap) onMapCreated;
  final VoidCallback? onUserCameraInteraction;

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PolylineAnnotation? _routeLine;

  // Throttle para câmera - evita chamadas excessivas
  DateTime _lastCameraUpdate = DateTime.now();
  static const _cameraThrottleMs = 250; // Máximo uma atualização a cada 250ms

  // Estilo do mapa (dark theme para combinar com o app)
  static const String _mapStyleUri = MapboxStyles.DARK;

  // Controle de câmera programática vs interação do usuário
  bool _isProgrammaticCameraChange = false;
  DateTime _lastUserInteraction = DateTime.fromMillisecondsSinceEpoch(0);
  static const _userInteractionThrottleMs = 400;
  static const _lookAheadMeters = 60.0;
  static const _driveAnimationMs = 320;
  static const _driveCameraThrottleMs = 250;
  bool _isDriveCameraAnimating = false;
  DateTime _lastDriveCameraUpdate = DateTime.fromMillisecondsSinceEpoch(0);


  @override
  void didUpdateWidget(covariant MapboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Atualiza câmera se seguindo usuário (com throttle)
    if (widget.mapState.userPosition != null &&
        widget.mapState.isFollowingUser &&
        (widget.mapState.userPosition != oldWidget.mapState.userPosition ||
         widget.mapState.userHeading != oldWidget.mapState.userHeading)) {
      _updateCameraWithThrottle();
    }

    // Atualiza a rota se mudou
    if (widget.mapState.activeRoute != oldWidget.mapState.activeRoute) {
      _updateRouteLayer();
    }

    // Atualiza modo da câmera (gestos, bearing, etc)
    if (widget.mapState.mode != oldWidget.mapState.mode) {
      _updateCameraMode();
      // Transição suave entre modos
      if (widget.mapState.userPosition != null && widget.mapState.isFollowingUser) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _animateCameraToUser();
        });
      }
    }

    if (widget.mapState.isFollowingUser && !oldWidget.mapState.isFollowingUser) {
      _animateCameraToUser();
    }

    // Preview: enquadra a rota inteira com transição suave
    if (widget.mapState.mode == MapMode.preview &&
        (widget.mapState.activeRoute != oldWidget.mapState.activeRoute ||
            oldWidget.mapState.mode != MapMode.preview)) {
      _animateCameraToRouteOverview();
    }
  }

  /// Callback quando o mapa é criado
  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    widget.onMapCreated(mapboxMap);

    // Configura os managers de anotação para rotas
    _polylineAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();

    // Desabilita rotação por gestos no modo normal
    await mapboxMap.gestures.updateSettings(GesturesSettings(
      rotateEnabled: false,
      pitchEnabled: false,
    ));

    // Remove ornamentos do mapa (barra de escala, logo, atribuição, bússola)
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    await mapboxMap.attribution.updateSettings(AttributionSettings(clickable: false));
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));

    // ═══════════════════════════════════════════════════════════════════════
    // PUCK NATIVO DO MAPBOX COM SETA CUSTOMIZADA
    // O puck é renderizado nativamente pelo SDK, sem precisar de 
    // pixelForCoordinate ou setState a cada frame
    // ═══════════════════════════════════════════════════════════════════════
    await _enableLocationPuckWithArrow();

    // Configura a posição inicial se disponível
    if (widget.mapState.userPosition != null) {
      await _setInitialCamera(widget.mapState.userPosition!);
    }
  }

  /// Gera imagem PNG de uma seta direcional
  Future<Uint8List> _createArrowImage() async {
    const size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Cor da seta (laranja do app)
    final arrowPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Glow/sombra
    final glowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Borda branca
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    const centerX = size / 2;
    const centerY = size / 2;
    const arrowHeight = 36.0;
    const arrowWidth = 28.0;

    // Path da seta apontando para cima
    final arrowPath = Path()
      ..moveTo(centerX, centerY - arrowHeight / 2) // Ponta
      ..lineTo(centerX - arrowWidth / 2, centerY + arrowHeight / 2) // Esquerda
      ..lineTo(centerX, centerY + arrowHeight / 4) // Centro inferior
      ..lineTo(centerX + arrowWidth / 2, centerY + arrowHeight / 2) // Direita
      ..close();

    // Desenha glow primeiro
    canvas.drawPath(arrowPath, glowPaint);
    // Depois a seta
    canvas.drawPath(arrowPath, arrowPaint);
    // Depois a borda
    canvas.drawPath(arrowPath, borderPaint);

    // Converte para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Habilita o puck nativo do Mapbox com imagem de seta customizada
  Future<void> _enableLocationPuckWithArrow() async {
    if (_mapboxMap == null) return;

    // Gera a imagem da seta
    final arrowImageBytes = await _createArrowImage();

    // Configuração do puck 2D com seta customizada
    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true, // Efeito de pulso
        pulsingColor: AppColors.accent.value,
        pulsingMaxRadius: 35.0,
        showAccuracyRing: false, // Visual mais limpo
        locationPuck: LocationPuck(
          locationPuck2D: LocationPuck2D(
            // Usa a imagem de seta customizada
            topImage: arrowImageBytes,
            // bearingImage rotaciona com o heading do GPS
            bearingImage: arrowImageBytes,
            shadowImage: null, // Sem sombra extra
          ),
        ),
      ),
    );
  }

  /// Define a câmera inicial (sem animação)
  Future<void> _setInitialCamera(MapPoint position) async {
    if (_mapboxMap == null) return;

    _markProgrammaticCameraChange(120);
    await _mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: widget.mapState.currentZoom,
        bearing: 0,
        pitch: 0,
      ),
    );
  }

  /// Atualiza a câmera com throttle para evitar chamadas excessivas
  /// 
  /// OTIMIZAÇÃO: Só permite uma atualização a cada 250ms no máximo.
  /// Isso evita que o stream de GPS cause dezenas de animações por segundo.
  void _updateCameraWithThrottle() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastCameraUpdate).inMilliseconds;

    if (elapsed < _cameraThrottleMs) {
      // Ainda não passou tempo suficiente, ignora
      return;
    }

    _lastCameraUpdate = now;
    _animateCameraToUser();
  }

  /// Anima a câmera para seguir o usuário
  /// 
  /// OTIMIZAÇÃO: Usa easeTo em vez de flyTo
  /// - easeTo: animação linear simples, mais leve
  /// - flyTo: animação com zoom out/in, mais pesada
  /// 
  /// MODO DRIVE (estilo Waze):
  /// - Zoom maior (18.0)
  /// - Pitch de 60° para visão "à frente"
  /// - Bearing baseado na direção do movimento
  /// - Câmera posicionada mais para baixo (não centralizada)
  Future<void> _animateCameraToUser() async {
    if (_mapboxMap == null || widget.mapState.userPosition == null) return;

    final position = widget.mapState.userPosition!;
    final isDriveMode = widget.mapState.mode == MapMode.drive;

    if (isDriveMode) {
      // ═══════════════════════════════════════════════════════════════════════
      // MODO DRIVE - ESTILO WAZE
      // ═══════════════════════════════════════════════════════════════════════
      // Câmera mais próxima, com visão "à frente" do veículo
      // Padding inferior para posicionar o usuário mais para baixo (efeito Waze)
      await _updateDriveCamera(position, widget.mapState.userHeading);
    } else {
      // ═══════════════════════════════════════════════════════════════════════
      // MODO NORMAL
      // ═══════════════════════════════════════════════════════════════════════
      final zoom = widget.mapState.currentZoom;
      final bearing = 0.0;
      final pitch = 0.0;

      _markProgrammaticCameraChange(250);
      await _mapboxMap!.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: zoom,
          bearing: bearing,
          pitch: pitch,
        ),
        MapAnimationOptions(
          duration: 250,
          startDelay: 0,
        ),
      );
    }
  }

  /// Move a câmera para uma posição (usado para ações manuais)
  Future<void> moveCameraToPosition(MapPoint position, {bool animate = true}) async {
    if (_mapboxMap == null) return;

    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(position.longitude, position.latitude),
      ),
      zoom: widget.mapState.currentZoom,
      bearing: widget.mapState.mode == MapMode.drive
          ? widget.mapState.userHeading
          : 0.0,
      pitch: widget.mapState.appropriateTilt,
    );

    if (animate) {
      _markProgrammaticCameraChange(300);
      await _mapboxMap!.easeTo(
        cameraOptions,
        MapAnimationOptions(duration: 300),
      );
    } else {
      _markProgrammaticCameraChange(120);
      await _mapboxMap!.setCamera(cameraOptions);
    }
  }

  /// Atualiza a layer da rota (ativa)
  Future<void> _updateRouteLayer() async {
    if (_polylineAnnotationManager == null) return;

    // Remove rota antiga
    if (_routeLine != null) {
      await _polylineAnnotationManager!.delete(_routeLine!);
      _routeLine = null;
    }

    // Se não há rota ativa, retorna
    if (widget.mapState.activeRoute == null) return;

    final route = widget.mapState.activeRoute!;
    if (route.coordinates.isEmpty) return;

    // Cria as coordenadas da polyline
    final coordinates = route.coordinates
        .map((p) => Position(p.longitude, p.latitude))
        .toList();

    // Desenha a rota
    _routeLine = await _polylineAnnotationManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coordinates),
        lineColor: AppColors.accent.value,
        lineWidth: 6.0,
        lineOpacity: 0.9,
      ),
    );
  }

  /// Atualiza a câmera no modo Drive com throttle e sem backlog.
  Future<void> _updateDriveCamera(MapPoint position, double heading) async {
    if (_mapboxMap == null) return;
    if (!widget.mapState.isNavigating || !widget.mapState.isFollowingUser) return;

    final now = DateTime.now();
    if (now.difference(_lastDriveCameraUpdate).inMilliseconds < _driveCameraThrottleMs) {
      return;
    }
    if (_isDriveCameraAnimating) return;

    _lastDriveCameraUpdate = now;
    _isDriveCameraAnimating = true;

    final target = _applyLookAhead(position, heading);
    _markProgrammaticCameraChange(_driveAnimationMs + 60);

    await _mapboxMap!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(target.longitude, target.latitude),
        ),
        zoom: widget.mapState.appropriateZoom,
        bearing: heading,
        pitch: widget.mapState.appropriateTilt,
      ),
      MapAnimationOptions(
        duration: _driveAnimationMs,
        startDelay: 0,
      ),
    );

    Future.delayed(const Duration(milliseconds: _driveAnimationMs), () {
      _isDriveCameraAnimating = false;
    });
  }

  /// Faz o overview da rota (camera transition do preview)
  Future<void> _animateCameraToRouteOverview() async {
    if (_mapboxMap == null || widget.mapState.activeRoute == null) return;

    final route = widget.mapState.activeRoute!;
    if (route.coordinates.isEmpty) return;

    double minLat = route.coordinates.first.latitude;
    double maxLat = route.coordinates.first.latitude;
    double minLon = route.coordinates.first.longitude;
    double maxLon = route.coordinates.first.longitude;

    for (final point in route.coordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLon, minLat)),
      northeast: Point(coordinates: Position(maxLon, maxLat)),
      infiniteBounds: false,
    );

    final padding = MbxEdgeInsets(
      top: 180,
      left: 56,
      right: 56,
      bottom: 320,
    );

    final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
      bounds,
      padding,
      0.0,
      0.0,
    );

    if (cameraOptions != null) {
      _markProgrammaticCameraChange(700);
      await _mapboxMap!.easeTo(
        cameraOptions,
        MapAnimationOptions(
          duration: 700,
          startDelay: 0,
        ),
      );
    }
  }

  /// Atualiza o modo da câmera (Normal vs Drive)
  Future<void> _updateCameraMode() async {
    if (_mapboxMap == null) return;

    final isDriveMode = widget.mapState.mode == MapMode.drive;

    // Habilita/desabilita gestos baseado no modo
    await _mapboxMap!.gestures.updateSettings(GesturesSettings(
      rotateEnabled: isDriveMode,
      pitchEnabled: isDriveMode,
    ));

    // Atualiza a câmera para o modo apropriado
    if (widget.mapState.userPosition != null && widget.mapState.isFollowingUser) {
      _animateCameraToUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Posição inicial (São Paulo como fallback)
    final initialPosition = widget.mapState.userPosition ??
        const MapPoint(latitude: -23.550520, longitude: -46.633308);

    // Widget simples sem overlay - o puck nativo cuida da localização
    return MapWidget(
      key: const ValueKey('mapbox_map'),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            initialPosition.longitude,
            initialPosition.latitude,
          ),
        ),
        zoom: widget.mapState.currentZoom,
        bearing: 0,
        pitch: 0,
      ),
      styleUri: _mapStyleUri,
      onMapCreated: _onMapCreated,
      onCameraChangeListener: _handleCameraChange,
    );
  }

  void _handleCameraChange(CameraChangedEventData eventData) {
    if (_isProgrammaticCameraChange) return;
    if (widget.onUserCameraInteraction == null) return;

    final now = DateTime.now();
    if (now.difference(_lastUserInteraction).inMilliseconds < _userInteractionThrottleMs) {
      return;
    }
    _lastUserInteraction = now;
    widget.onUserCameraInteraction!.call();
  }

  void _markProgrammaticCameraChange(int durationMs) {
    _isProgrammaticCameraChange = true;
    Future.delayed(Duration(milliseconds: durationMs), () {
      _isProgrammaticCameraChange = false;
    });
  }

  MapPoint _applyLookAhead(MapPoint point, double bearingDegrees) {
    final bearingRad = bearingDegrees * (pi / 180);
    final distanceRatio = _lookAheadMeters / 6378137.0;
    final latRad = point.latitude * (pi / 180);
    final lonRad = point.longitude * (pi / 180);

    final newLat = asin(
      sin(latRad) * cos(distanceRatio) +
          cos(latRad) * sin(distanceRatio) * cos(bearingRad),
    );
    final newLon = lonRad +
        atan2(
          sin(bearingRad) * sin(distanceRatio) * cos(latRad),
          cos(distanceRatio) - sin(latRad) * sin(newLat),
        );

    return MapPoint(
      latitude: newLat * (180 / pi),
      longitude: newLon * (180 / pi),
    );
  }
}

/// Botão de controle do mapa (zoom, localização)
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isAccent = false,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isAccent
              ? AppColors.accent
              : AppColors.darkGrey.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccent ? AppColors.accent : AppColors.mediumGrey,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              )
            : Icon(
                icon,
                color: AppColors.white,
                size: 22,
              ),
      ),
    );
  }
}

/// Toggle para alternar entre modo Normal e Drive
class MapModeToggle extends StatelessWidget {
  const MapModeToggle({
    super.key,
    required this.currentMode,
    required this.onToggle,
    this.hasDestination = false,
  });

  final MapMode currentMode;
  final VoidCallback onToggle;
  final bool hasDestination;

  @override
  Widget build(BuildContext context) {
    final isDriveMode = currentMode == MapMode.drive;

    return GestureDetector(
      onTap: hasDestination || isDriveMode ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDriveMode
              ? AppColors.accent
              : AppColors.darkGrey.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDriveMode ? AppColors.accent : AppColors.mediumGrey,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDriveMode ? AppColors.accent : Colors.black)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDriveMode ? Icons.navigation_rounded : Icons.explore_rounded,
              color: isDriveMode
                  ? AppColors.white
                  : (hasDestination ? AppColors.accent : AppColors.lightGrey),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isDriveMode ? 'DRIVE' : 'NORMAL',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDriveMode
                    ? AppColors.white
                    : (hasDestination ? AppColors.white : AppColors.lightGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
