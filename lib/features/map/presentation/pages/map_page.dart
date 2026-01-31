import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_bloc.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_event.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_state.dart';
import 'package:gearhead_br/features/map/presentation/widgets/mapbox_map_widget.dart';
import 'package:gearhead_br/features/map/presentation/widgets/navigation_panel.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart'
    as nav_entities;

/// Página do Mapa - Tela principal do app
/// Exibe localização, eventos e usuários próximos
/// Suporta dois modos: Normal (tracking) e Drive (navegação)
/// 
/// OTIMIZAÇÃO: Usa MapBloc como singleton para manter estado entre navegações.
/// Isso evita recarregar o mapa toda vez que o usuário volta para esta tela.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapBloc _mapBloc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mapBloc = getIt<MapBloc>();
    
    // Inicializa apenas uma vez se ainda não tiver posição
    if (_mapBloc.state.userPosition == null && !_initialized) {
      _initialized = true;
      _mapBloc.add(const MapInitialized());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapBloc,
      child: const _MapPageContent(),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  const _MapPageContent();

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent> {
  MapboxMap? _mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BlocConsumer<MapBloc, MapState>(
        listenWhen: (previous, current) =>
            previous.locationError != current.locationError &&
            current.locationError != null,
        listener: (context, state) {
          // Mostra snackbar em caso de erro
          if (state.locationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.locationError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          // ═══════════════════════════════════════════════════════════════════
          // LOADING FULLSCREEN: Mostra loading até ter localização do usuário
          // Isso evita mostrar o mapa em posição errada e depois "pular"
          // ═══════════════════════════════════════════════════════════════════
          if (state.userPosition == null) {
            return _buildFullScreenLoading(context, state);
          }

          return Stack(
            children: [
              // Mapa Mapbox - só exibe quando tem localização
              MapboxMapWidget(
                mapState: state,
                onUserCameraInteraction: () {
                  context.read<MapBloc>().add(const CameraFollowDisabled());
                },
                onMapCreated: (mapboxMap) {
                  _mapboxMap = mapboxMap;
                },
              ),

              // Painel de navegação (visível apenas no modo Drive)
              if (state.isNavigating)
                NavigationPanel(
                  mapState: state,
                  onStopNavigation: () {
                    context.read<MapBloc>().add(const NavigationStopped());
                  },
                ),

              // Badge de limite de velocidade (modo Drive)
              if (state.isNavigating)
                Positioned(
                  left: 16,
                  bottom: 110,
                  child: SafeArea(
                    top: false,
                    right: false,
                    child: SpeedLimitBadge(speedLimitKmh: state.speedLimitKmh),
                  ),
                ),

              // Header overlay (search bar) - oculto durante navegação
              if (!state.isNavigating) _buildHeader(context, state),

              // Botões de controle do mapa
              _buildMapControls(context, state),

              // Botão de recentralizar no modo Drive
              if (state.isNavigating && !state.isFollowingUser)
                Positioned(
                  right: 16,
                  bottom: 110,
                  child: SafeArea(
                    top: false,
                    left: false,
                    child: MapControlButton(
                      icon: Icons.my_location,
                      isAccent: true,
                      onTap: () {
                        context.read<MapBloc>().add(const CameraCenteredOnUser());
                      },
                    ),
                  ),
                ),

              // Preview de rota com botões de iniciar/cancelar
              if (state.hasDestination && !state.isNavigating)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RoutePreviewPanel(
                    mapState: state,
                    onStartNavigation: () {
                      context.read<MapBloc>().add(
                            NavigationStarted(
                              destination: state.selectedDestination!,
                            ),
                          );
                    },
                    onCancel: () {
                      context.read<MapBloc>().add(const RoutePreviewCancelled());
                    },
                  ),
                ),

              // Bottom Navigation
              if (!state.isNavigating)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNavBar(currentItem: NavItem.map),
                ),

              // Indicador de erro de localização (dentro do mapa)
              if (state.locationError != null && !state.isNavigating)
                _buildErrorIndicator(context, state),
            ],
          );
        },
      ),
    );
  }

  /// Loading fullscreen enquanto obtém localização
  Widget _buildFullScreenLoading(BuildContext context, MapState state) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone animado
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.accent,
                      size: 40,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Repetir animação
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 24),
            
            // Texto de status
            Text(
              state.isLoadingLocation
                  ? 'Obtendo sua localização...'
                  : state.locationError != null
                      ? 'Erro ao obter localização'
                      : 'Iniciando mapa...',
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtexto
            Text(
              'Aguarde um momento',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppColors.lightGrey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicador de progresso ou botão de retry
            if (state.isLoadingLocation)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            else if (state.locationError != null)
              Column(
                children: [
                  Text(
                    state.locationError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(const MapInitialized());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Header com barra de busca
  Widget _buildHeader(BuildContext context, MapState state) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showSearchSheet(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mediumGrey),
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
                ),
                const SizedBox(width: 12),
                MapControlButton(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilters(context),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  /// Botões de controle do mapa (zoom, localização)
  /// No modo drive, os controles são removidos (estilo Waze)
  /// Ajusta o padding quando o botão CTA está visível
  Widget _buildMapControls(BuildContext context, MapState state) {
    // No modo drive, não exibe controles (estilo Waze)
    if (state.isNavigating) {
      return const SizedBox.shrink();
    }

    // Calcula o offset do bottom baseado no estado
    // - Preview (botão CTA visível): mais acima para evitar sobreposição
    //   Botão CTA tem ~80px altura + 100px margin bottom + safe area = ~240px
    // - Normal: padrão (120)
    final hasCTA = state.hasDestination && !state.isNavigating;
    final bottomOffset = hasCTA ? 240.0 : 120.0;

    final isPreview = state.isPreviewing;
    final topOffset = isPreview ? 132.0 : null;
    final bottom = isPreview ? null : bottomOffset;

    return Positioned(
      right: 16,
      top: topOffset,
      bottom: bottom,
      child: SafeArea(
        child: Column(
          children: [
            MapControlButton(
              icon: Icons.add,
              onTap: () {
                context.read<MapBloc>().add(const CameraZoomChanged(zoomIn: true));
                _zoomMap(true, state);
              },
            ),
            const SizedBox(height: 8),
            MapControlButton(
              icon: Icons.remove,
              onTap: () {
                context.read<MapBloc>().add(const CameraZoomChanged(zoomIn: false));
                _zoomMap(false, state);
              },
            ),
            const SizedBox(height: 16),
            MapControlButton(
              icon: state.isFollowingUser
                  ? Icons.my_location
                  : Icons.location_searching,
              isAccent: state.isFollowingUser,
              isLoading: state.isLoadingLocation,
              onTap: () {
                context.read<MapBloc>().add(const CameraCenteredOnUser());
                _centerOnUser(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Indicador de erro
  Widget _buildErrorIndicator(BuildContext context, MapState state) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.locationError ?? 'Erro desconhecido',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppColors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.white, size: 20),
              onPressed: () {
                context.read<MapBloc>().add(const MapInitialized());
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  /// Aplica zoom no mapa
  /// Usa easeTo em vez de flyTo - mais leve para interações do usuário
  void _zoomMap(bool zoomIn, MapState state) {
    if (_mapboxMap == null) return;

    final currentZoom = state.currentZoom;
    final newZoom = zoomIn
        ? (currentZoom + 1).clamp(5.0, 20.0)
        : (currentZoom - 1).clamp(5.0, 20.0);

    _mapboxMap!.easeTo(
      CameraOptions(zoom: newZoom),
      MapAnimationOptions(duration: 250),
    );
  }

  /// Centraliza no usuário
  /// Usa easeTo em vez de flyTo - mais leve e suave
  void _centerOnUser(MapState state) {
    if (_mapboxMap == null || state.userPosition == null) return;

    final position = state.userPosition!;
    _mapboxMap!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: state.appropriateZoom,
        bearing: state.mode == MapMode.drive ? state.userHeading : 0,
        pitch: state.appropriateTilt,
      ),
      MapAnimationOptions(duration: 350),
    );
  }

  /// Exibe sheet de busca
  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkGrey,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => _SearchSheet(
          scrollController: controller,
          onDestinationSelected: (destination) {
            Navigator.pop(sheetContext);
            context.read<MapBloc>().add(
                  DestinationSelected(destination: destination),
                );
          },
        ),
      ),
    );
  }

  /// Exibe filtros
  void _showFilters(BuildContext context) {
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
            _FilterOption(
              icon: Icons.event_rounded,
              label: 'Eventos',
              isSelected: true,
            ),
            _FilterOption(
              icon: Icons.groups_rounded,
              label: 'Crews',
              isSelected: true,
            ),
            _FilterOption(
              icon: Icons.local_gas_station_rounded,
              label: 'Postos',
              isSelected: false,
            ),
            _FilterOption(
              icon: Icons.car_repair_rounded,
              label: 'Oficinas',
              isSelected: false,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Sheet de busca de destinos
class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.scrollController,
    required this.onDestinationSelected,
  });

  final ScrollController scrollController;
  final void Function(nav_entities.NavigationDestination) onDestinationSelected;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _searchController = TextEditingController();
  List<_SearchResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Carrega sugestões iniciais (POIs mockados)
    _loadInitialSuggestions();
  }

  void _loadInitialSuggestions() {
    setState(() {
      _results = [
        _SearchResult(
          name: 'Encontro de Carros Antigos',
          address: 'Praça da Sé, Centro - São Paulo',
          type: 'Evento',
          icon: Icons.event_rounded,
          point: const nav_entities.MapPoint(latitude: -23.5505, longitude: -46.6333),
        ),
        _SearchResult(
          name: 'Crew SP Tuning',
          address: 'Av. Paulista, 1000 - São Paulo',
          type: 'Crew',
          icon: Icons.groups_rounded,
          point: const nav_entities.MapPoint(latitude: -23.5614, longitude: -46.6558),
        ),
        _SearchResult(
          name: 'Auto Center Premium',
          address: 'R. Augusta, 500 - São Paulo',
          type: 'Oficina',
          icon: Icons.car_repair_rounded,
          point: const nav_entities.MapPoint(latitude: -23.5534, longitude: -46.6608),
        ),
        _SearchResult(
          name: 'Posto Shell Premium',
          address: 'Av. Brasil, 2500 - São Paulo',
          type: 'Posto',
          icon: Icons.local_gas_station_rounded,
          point: const nav_entities.MapPoint(latitude: -23.5456, longitude: -46.6388),
        ),
      ];
    });
  }

  void _search(String query) async {
    if (query.isEmpty) {
      _loadInitialSuggestions();
      return;
    }

    setState(() => _isSearching = true);

    // Simula busca (em produção, usar Mapbox Geocoding API)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSearching = false;
      // Filtra resultados pelo query
      _results = _results
          .where((r) =>
              r.name.toLowerCase().contains(query.toLowerCase()) ||
              r.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.mediumGrey,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Campo de busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            style: GoogleFonts.rajdhani(
              color: AppColors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Para onde?',
              hintStyle: GoogleFonts.rajdhani(
                color: AppColors.lightGrey,
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.lightGrey,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.lightGrey),
                      onPressed: () {
                        _searchController.clear();
                        _loadInitialSuggestions();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.mediumGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.mediumGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ),

        // Resultados
        Expanded(
          child: _isSearching
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return _SearchResultTile(
                      result: result,
                      onTap: () {
                        widget.onDestinationSelected(
                          nav_entities.NavigationDestination(
                            point: result.point,
                            name: result.name,
                            address: result.address,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Resultado de busca
class _SearchResult {
  const _SearchResult({
    required this.name,
    required this.address,
    required this.type,
    required this.icon,
    required this.point,
  });

  final String name;
  final String address;
  final String type;
  final IconData icon;
  final nav_entities.MapPoint point;
}

/// Tile de resultado de busca
class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onTap,
  });

  final _SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          result.icon,
          color: AppColors.accent,
          size: 24,
        ),
      ),
      title: Text(
        result.name,
        style: GoogleFonts.rajdhani(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.address,
            style: GoogleFonts.rajdhani(
              color: AppColors.lightGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.mediumGrey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.type,
              style: GoogleFonts.rajdhani(
                color: AppColors.lightGrey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.navigation_rounded,
        color: AppColors.accent,
        size: 20,
      ),
    );
  }
}

/// Opção de filtro
class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.mediumGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.accent : AppColors.lightGrey,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.rajdhani(
          color: isSelected ? AppColors.white : AppColors.lightGrey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: isSelected,
        onChanged: (_) {
          // TODO: Implementar toggle de filtro
        },
        activeColor: AppColors.accent,
        activeTrackColor: AppColors.accent.withOpacity(0.3),
        inactiveThumbColor: AppColors.lightGrey,
        inactiveTrackColor: AppColors.mediumGrey,
      ),
    );
  }
}
