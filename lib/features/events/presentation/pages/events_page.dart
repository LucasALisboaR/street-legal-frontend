import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';

/// Página de Eventos
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EVENTOS',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Encontros e rolês',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.calendar_month_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.add_rounded,
                        isAccent: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Criar evento em desenvolvimento'),
                              backgroundColor: AppColors.accent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(label: 'Todos', isActive: true, onTap: () {}),
                  _FilterChip(label: '🚗 Encontro', isActive: false, onTap: () {}),
                  _FilterChip(label: '🏆 Exposição', isActive: false, onTap: () {}),
                  _FilterChip(label: '🛣️ Rolê', isActive: false, onTap: () {}),
                  _FilterChip(label: '🏁 Track Day', isActive: false, onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de Eventos
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _SectionTitle(title: 'HOJE'),
                  const SizedBox(height: 12),
                  const _EventCard(
                    title: 'Encontro Noturno SP',
                    type: '🚗 Encontro',
                    location: 'Av. Paulista, São Paulo',
                    time: '21:00',
                    participantCount: 45,
                    isLive: true,
                  ),
                  const SizedBox(height: 12),
                  const _EventCard(
                    title: 'Cars & Coffee Alphaville',
                    type: '🏆 Exposição',
                    location: 'Shopping Iguatemi',
                    time: '08:00 - 12:00',
                    participantCount: 128,
                    isLive: false,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'ESTA SEMANA'),
                  const SizedBox(height: 12),
                  const _EventCard(
                    title: 'Rolê Serra da Cantareira',
                    type: '🛣️ Rolê',
                    location: 'Saída: Posto Shell Santana',
                    time: 'Sáb, 07:00',
                    participantCount: 23,
                    isLive: false,
                  ),
                  const SizedBox(height: 12),
                  const _EventCard(
                    title: 'Track Day Interlagos',
                    type: '🏁 Track Day',
                    location: 'Autódromo de Interlagos',
                    time: 'Dom, 06:00 - 18:00',
                    participantCount: 67,
                    isLive: false,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Navigation
            const BottomNavBar(currentItem: NavItem.events),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isAccent ? AppColors.accent : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccent ? AppColors.accent : AppColors.mediumGrey,
            width: 1,
          ),
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
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.darkGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.mediumGrey,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.white : AppColors.lightGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        letterSpacing: 2,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String type;
  final String location;
  final String time;
  final int participantCount;
  final bool isLive;

  const _EventCard({
    required this.title,
    required this.type,
    required this.location,
    required this.time,
    required this.participantCount,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.accent.withOpacity(0.5) : AppColors.mediumGrey,
          width: isLive ? 2 : 1,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
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
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.lightGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.lightGrey,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppColors.lightGrey,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                '$participantCount',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

