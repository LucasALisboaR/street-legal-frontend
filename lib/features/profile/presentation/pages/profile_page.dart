import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/profile/presentation/widgets/garage_section.dart';

/// Página de Perfil do usuário
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GarageBloc()..add(const GarageLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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
                  Text(
                    'PERFIL',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.settings_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.logout_rounded,
                        onTap: () => _showLogoutConfirmation(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: ListView(
                children: [
                  // Informações do usuário
                  const _UserInfoSection(),

                  const SizedBox(height: 24),

                  // Estatísticas
                  const _StatsSection(),

                  const SizedBox(height: 24),

                  // Garagem
                  const GarageSection(),

                  const SizedBox(height: 24),

                  // Menu de opções
                  const _MenuSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Navigation
            const BottomNavBar(currentItem: NavItem.profile),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sair do app?',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você será desconectado da sua conta.',
          style: GoogleFonts.rajdhani(
            color: AppColors.lightGrey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.rajdhani(
                color: AppColors.lightGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRouter.login);
            },
            child: Text(
              'Sair',
              style: GoogleFonts.rajdhani(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGrey,
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

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentDark],
              ),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'GH',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
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
                  'Piloto GEARHEAD',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@piloto_gearhead',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(label: '🏆 Nível 5'),
                    const SizedBox(width: 8),
                    _Badge(label: '🔥 Ativo'),
                  ],
                ),
              ],
            ),
          ),

          // Editar
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.mediumGrey,
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.mediumGrey,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.mediumGrey,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: '12', label: 'Eventos'),
            _Divider(),
            _StatItem(value: '3', label: 'Crews'),
            _Divider(),
            _StatItem(value: '156', label: 'Seguidores'),
            _Divider(),
            _StatItem(value: '89', label: 'Seguindo'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.mediumGrey,
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.history_rounded,
            label: 'Histórico de eventos',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.bookmark_outline,
            label: 'Salvos',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.shield_outlined,
            label: 'Privacidade',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Ajuda & Suporte',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.info_outline,
            label: 'Sobre o app',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.mediumGrey,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.lightGrey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightGrey,
            ),
          ],
        ),
      ),
    );
  }
}

