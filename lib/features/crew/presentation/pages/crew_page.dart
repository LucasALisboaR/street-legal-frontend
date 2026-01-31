import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/app_icon_button.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';

/// Página de Crews - Lista de grupos/equipes
class CrewPage extends StatelessWidget {
  const CrewPage({super.key});

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
                        'CREWS',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Encontre sua equipe',
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
                        icon: Icons.search_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Criar crew em desenvolvimento'),
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

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TabButton(label: 'Minhas', isActive: true, onTap: () {}),
                  const SizedBox(width: 12),
                  _TabButton(label: 'Descobrir', isActive: false, onTap: () {}),
                  const SizedBox(width: 12),
                  _TabButton(label: 'Próximas', isActive: false, onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de Crews
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _CrewCard(
                    name: 'Opala Clube SP',
                    description: 'Encontros semanais de Opalas em São Paulo',
                    memberCount: 156,
                    location: 'São Paulo, SP',
                    imageInitial: 'OC',
                  ),
                  SizedBox(height: 12),
                  _CrewCard(
                    name: 'VW Ar Brasil',
                    description: 'Comunidade de veículos VW refrigerados a ar',
                    memberCount: 342,
                    location: 'Nacional',
                    imageInitial: 'VW',
                  ),
                  SizedBox(height: 12),
                  _CrewCard(
                    name: 'Turbo Gang',
                    description: 'Para quem curte pressão positiva',
                    memberCount: 89,
                    location: 'Campinas, SP',
                    imageInitial: 'TG',
                  ),
                  SizedBox(height: 12),
                  _CrewCard(
                    name: 'Muscle Cars BR',
                    description: 'V8 americanos no Brasil',
                    memberCount: 234,
                    location: 'Nacional',
                    imageInitial: 'MC',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Navigation
            const BottomNavBar(currentItem: NavItem.crew),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {

  const _IconButton({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: icon,
      onPressed: onTap,
    );
  }
}

class _TabButton extends StatelessWidget {

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.mediumGrey,
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
    );
  }
}

class _CrewCard extends StatelessWidget {

  const _CrewCard({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.location,
    required this.imageInitial,
  });
  final String name;
  final String description;
  final int memberCount;
  final String location;
  final String imageInitial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGrey,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                imageInitial,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.lightGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$memberCount membros',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.lightGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }
}
