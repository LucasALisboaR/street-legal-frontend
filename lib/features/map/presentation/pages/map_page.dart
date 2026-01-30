import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart' as map_repo;
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

/// Página do Mapa - Tela principal do app
/// Exibe localização, eventos e usuários próximos
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _fabAnimationController;
  late AnimationController _markerAnimationController;
  late MapRepository _mapRepository;
  late LocationService _locationService;
  StreamSubscription<Position>? _locationSubscription;
  final StreamController<Position> _positionStreamController = StreamController<Position>.broadcast();

  // Localização atual do usuário
  LatLng? _currentLocation;
  LatLng? _targetLocation;
  double _currentHeading = 0.0;
  double _targetHeading = 0.0;
  bool _isLoadingLocation = true;
  String? _locationError;

  /// Calcula o heading (direção) entre duas coordenadas
  double _calculateHeading(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var heading = math.atan2(y, x);
    heading = heading * 180 / math.pi;
    heading = (heading + 360) % 360; // Normaliza para 0-360

    return heading;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _mapRepository = getIt<MapRepository>();
    _locationService = getIt<LocationService>();
    
    _loadCurrentLocation();
    // Inicia stream de localização em tempo real
    _startLocationStream();
  }

  /// Inicia o stream de localização em tempo real
  Future<void> _startLocationStream() async {
    // Aguarda a primeira localização ser carregada
    await Future<void>.delayed(const Duration(seconds: 2));

    // Verifica permissões
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) return;

    // Inicia o stream de localização
    // distanceFilter: 10 metros - atualiza quando o usuário se move pelo menos 10m
    _locationSubscription = _locationService.getPositionStream(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // metros - reduz frequência de atualizações
    ).listen(
      (position) {
        if (mounted && !_isLoadingLocation) {
          final newLocation = LatLng(position.latitude, position.longitude);
          
          // Calcula heading se disponível, senão calcula baseado no movimento
          double newHeading = _currentHeading;
          if (position.heading.isFinite && position.heading > 0) {
            newHeading = position.heading;
          } else if (_currentLocation != null) {
            newHeading = _calculateHeading(_currentLocation!, newLocation);
          }
          
          // Atualiza apenas se a localização mudou significativamente
          if (_currentLocation == null || 
              (newLocation.latitude != _currentLocation!.latitude || 
               newLocation.longitude != _currentLocation!.longitude)) {
            setState(() {
              _targetLocation = newLocation;
              _targetHeading = newHeading;
            });

            // Inicia animação
            _markerAnimationController.forward(from: 0.0);

            // Envia posição para o stream
            _positionStreamController.add(position);

            // Salva a última posição (sem await para não bloquear)
            _saveUserLocation(LocationEntity(
              latitude: position.latitude,
              longitude: position.longitude,
              timestamp: position.timestamp,
            ));
          }
        }
      },
      onError: (error) {
        // Ignora erros no stream silenciosamente
      },
    );
  }

  /// Salva a última posição do usuário
  Future<void> _saveUserLocation(LocationEntity location) async {
    await _mapRepository.updateUserLocation(location);
  }

  /// Carrega a localização atual do usuário
  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    final result = await _mapRepository.getCurrentLocation();

    result.fold(
      (failure) {
        setState(() {
          _isLoadingLocation = false;
          if (failure is map_repo.LocationPermissionFailure) {
            _locationError = 'Permissão de localização negada. Por favor, ative nas configurações.';
          } else if (failure is map_repo.LocationServiceFailure) {
            _locationError = 'Serviço de localização desativado. Por favor, ative o GPS.';
          } else {
            _locationError = 'Erro ao obter localização.';
          }
          // Usa localização padrão (São Paulo) se não conseguir obter
          _currentLocation = const LatLng(-23.550520, -46.633308);
        });
      },
      (location) {
        if (mounted) {
          final newLocation = LatLng(location.latitude, location.longitude);
          final isFirstLoad = _currentLocation == null;
          
          setState(() {
            _isLoadingLocation = false;
            _currentLocation = newLocation;
            _targetLocation = newLocation;
            _locationError = null;
          });
          
          // Envia posição inicial para o stream
          _positionStreamController.add(
            Position(
              latitude: location.latitude,
              longitude: location.longitude,
              timestamp: location.timestamp,
              accuracy: 0,
              altitude: 0,
              heading: _currentHeading,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            ),
          );
          
          // Salva a última posição
          _saveUserLocation(location);
          // Move o mapa para a localização atual apenas na primeira vez
          if (isFirstLoad) {
            _mapController.move(newLocation, 15);
          }
        }
      },
    );
  }


  @override
  void dispose() {
    _locationSubscription?.cancel();
    _positionStreamController.close();
    _mapController.dispose();
    _fabAnimationController.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(-23.550520, -46.633308),
              initialZoom: 15,
              minZoom: 5,
              maxZoom: 18,
              backgroundColor: AppColors.black,
            ),
            children: [
              // Tile Layer (OpenStreetMap com estilo dark)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gearheadbr.app',
                retinaMode: true,
              ),

              // Marcador animado do usuário
              if (_currentLocation != null)
                AnimatedBuilder(
                  animation: _markerAnimationController,
                  builder: (context, child) {
                    // Interpola posição
                    final animatedLocation = _targetLocation != null &&
                            _currentLocation != null
                        ? LatLng(
                            _currentLocation!.latitude +
                                (_targetLocation!.latitude -
                                        _currentLocation!.latitude) *
                                    _markerAnimationController.value,
                            _currentLocation!.longitude +
                                (_targetLocation!.longitude -
                                        _currentLocation!.longitude) *
                                    _markerAnimationController.value,
                          )
                        : _currentLocation!;

                    // Interpola heading (trata ciclo 359° -> 0°)
                    double animatedHeading = _currentHeading;
                    if (_targetHeading != _currentHeading) {
                      var diff = _targetHeading - _currentHeading;
                      if (diff > 180) diff -= 360;
                      if (diff < -180) diff += 360;
                      animatedHeading = _currentHeading +
                          diff * _markerAnimationController.value;
                    }

                    // Atualiza posição atual quando animação termina
                    if (_markerAnimationController.isCompleted &&
                        _targetLocation != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _currentLocation = _targetLocation;
                            _currentHeading = _targetHeading;
                          });
                          _markerAnimationController.reset();
                        }
                      });
                    }

                    // Converte heading de graus para radianos
                    final headingRadians = animatedHeading * math.pi / 180;

                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: animatedLocation,
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Transform.rotate(
                            angle: headingRadians,
                            child: _DirectionArrowMarker(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),

          // Header overlay
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.search_rounded,
                                color: AppColors.lightGrey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Buscar eventos, crews, lugares...',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 14,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _MapButton(
                        icon: Icons.tune_rounded,
                        onTap: _showFilters,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // Botões do mapa (zoom, localização)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                ),
                const SizedBox(height: 16),
                _MapButton(
                  icon: _isLoadingLocation ? Icons.refresh : Icons.my_location,
                  isAccent: true,
                  onTap: () {
                    if (_currentLocation != null) {
                      _mapController.move(_currentLocation!, 15);
                    } else {
                      _loadCurrentLocation();
                    }
                  },
                ),
              ],
            ),
          ),


          // Bottom Navigation
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(currentItem: NavItem.map),
          ),

          // Indicador de carregamento ou erro
          if (_isLoadingLocation || _locationError != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _locationError != null
                      ? Colors.red.withOpacity(0.9)
                      : AppColors.darkGrey.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _locationError != null
                        ? Colors.red
                        : AppColors.mediumGrey,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      )
                    else
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isLoadingLocation
                            ? 'Obtendo localização...'
                            : _locationError ?? 'Erro desconhecido',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (_locationError != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.white, size: 20),
                        onPressed: _loadCurrentLocation,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILTROS',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filtros em desenvolvimento...',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                color: AppColors.lightGrey,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════════

class _MapButton extends StatelessWidget {

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.isAccent = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isAccent ? AppColors.accent : AppColors.darkGrey.withOpacity(0.95),
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
        child: Icon(
          icon,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}

/// Widget de seta direcional para o marcador do usuário
/// Aponta na direção do movimento com efeito glow
class _DirectionArrowMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Seta direcional
          CustomPaint(
            size: const Size(40, 40),
            painter: _ArrowPainter(),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter para desenhar a seta direcional
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final arrowSize = 16.0;

    // Desenha a seta apontando para cima (será rotacionada pelo Transform.rotate)
    path.moveTo(centerX, centerY - arrowSize / 2);
    path.lineTo(centerX - arrowSize / 2, centerY + arrowSize / 2);
    path.lineTo(centerX, centerY + arrowSize / 3);
    path.lineTo(centerX + arrowSize / 2, centerY + arrowSize / 2);
    path.close();

    canvas.drawPath(path, paint);

    // Adiciona um círculo central para melhor visualização
    final circlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 4, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
