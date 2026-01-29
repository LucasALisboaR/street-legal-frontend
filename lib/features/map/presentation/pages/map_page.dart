import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';

/// Página do Mapa - Tela principal do app
/// Exibe localização, eventos e usuários próximos
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _fabAnimationController;

  // Mock: localização atual (São Paulo)
  final LatLng _currentLocation = const LatLng(-23.550520, -46.633308);

  // Mock: eventos próximos
  final List<_MapEvent> _events = [
    const _MapEvent(
      id: '1',
      name: 'Encontro Noturno SP',
      location: LatLng(-23.561414, -46.656078),
      participants: 45,
      type: EventType.meetup,
      isLive: true,
    ),
    const _MapEvent(
      id: '2',
      name: 'Cars & Coffee',
      location: LatLng(-23.587416, -46.657333),
      participants: 128,
      type: EventType.carshow,
      isLive: false,
    ),
    const _MapEvent(
      id: '3',
      name: 'Track Day Interlagos',
      location: LatLng(-23.701389, -46.696944),
      participants: 67,
      type: EventType.race,
      isLive: false,
    ),
  ];

  // Mock: usuários próximos
  final List<_MapUser> _nearbyUsers = [
    const _MapUser(
      id: '1',
      name: 'Carlos_Turbo',
      vehicle: 'Civic Si',
      location: LatLng(-23.553520, -46.640308),
    ),
    const _MapUser(
      id: '2',
      name: 'Opala_do_Zé',
      vehicle: 'Opala 1988',
      location: LatLng(-23.545520, -46.628308),
    ),
    const _MapUser(
      id: '3',
      name: 'V8_Maniaco',
      vehicle: 'Mustang GT',
      location: LatLng(-23.558520, -46.650308),
    ),
  ];

  bool _showEvents = true;
  bool _showUsers = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _fabAnimationController.dispose();
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
              initialCenter: _currentLocation,
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

              // Marcadores
              MarkerLayer(
                markers: [
                  // Localização atual
                  Marker(
                    point: _currentLocation,
                    width: 50,
                    height: 50,
                    child: _CurrentLocationMarker(),
                  ),

                  // Eventos
                  if (_showEvents)
                    ..._events.map((event) => Marker(
                          point: event.location,
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _showEventDetails(event),
                            child: _EventMarker(event: event),
                          ),
                        ),),

                  // Usuários
                  if (_showUsers)
                    ..._nearbyUsers.map((user) => Marker(
                          point: user.location,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _showUserDetails(user),
                            child: _UserMarker(user: user),
                          ),
                        ),),
                ],
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

                // Filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        icon: Icons.event,
                        label: 'Eventos',
                        isActive: _showEvents,
                        onTap: () => setState(() => _showEvents = !_showEvents),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        icon: Icons.people,
                        label: 'Pilotos',
                        isActive: _showUsers,
                        onTap: () => setState(() => _showUsers = !_showUsers),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        icon: Icons.local_gas_station,
                        label: 'Postos',
                        isActive: false,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        icon: Icons.build,
                        label: 'Oficinas',
                        isActive: false,
                        onTap: () {},
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
                  icon: Icons.my_location,
                  isAccent: true,
                  onTap: () => _mapController.move(_currentLocation, 15),
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
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
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

  void _showEventDetails(_MapEvent event) {
    showModalBottomSheet(
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
            Row(
              children: [
                if (event.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AO VIVO',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  event.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  event.type.label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.name,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  '${event.participants} participantes',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('VER DETALHES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(_MapUser user) {
    showModalBottomSheet(
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
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.vehicle,
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.mediumGrey),
                    ),
                    child: const Text('Ver perfil'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mensagem'),
                  ),
                ),
              ],
            ),
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

class _FilterChip extends StatelessWidget {

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withOpacity(0.9)
              : AppColors.darkGrey.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.mediumGrey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withOpacity(0.2),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventMarker extends StatelessWidget {

  const _EventMarker({required this.event});
  final _MapEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: event.isLive ? AppColors.accent : AppColors.darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isLive ? AppColors.accent : AppColors.mediumGrey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: event.isLive
                ? AppColors.accent.withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          event.type.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {

  const _UserMarker({required this.user});
  final _MapUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
        ),
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          user.name[0].toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MODELOS
// ═══════════════════════════════════════════════════════════════════════════════

class _MapEvent {

  const _MapEvent({
    required this.id,
    required this.name,
    required this.location,
    required this.participants,
    required this.type,
    required this.isLive,
  });
  final String id;
  final String name;
  final LatLng location;
  final int participants;
  final EventType type;
  final bool isLive;
}

class _MapUser {

  const _MapUser({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.location,
  });
  final String id;
  final String name;
  final String vehicle;
  final LatLng location;
}

enum EventType {
  meetup,
  carshow,
  cruise,
  race,
  workshop,
}

extension EventTypeX on EventType {
  String get emoji => switch (this) {
        EventType.meetup => '🚗',
        EventType.carshow => '🏆',
        EventType.cruise => '🛣️',
        EventType.race => '🏁',
        EventType.workshop => '🔧',
      };

  String get label => switch (this) {
        EventType.meetup => 'Encontro',
        EventType.carshow => 'Exposição',
        EventType.cruise => 'Rolê',
        EventType.race => 'Track Day',
        EventType.workshop => 'Workshop',
      };
}
