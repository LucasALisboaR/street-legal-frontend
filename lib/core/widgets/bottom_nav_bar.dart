import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/router/app_router.dart';

/// Item de navegação
enum NavItem {
  map,
  crew,
  events,
  moments,
  profile,
}

/// Barra de navegação inferior reutilizável
/// Design inspirado na cultura automotiva com efeito neon
class BottomNavBar extends StatelessWidget {

  const BottomNavBar({
    super.key,
    required this.currentItem,
  });
  final NavItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        border: Border(
          top: BorderSide(
            color: AppColors.mediumGrey.withOpacity(0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItemWidget(
                item: NavItem.map,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Discover',
                isActive: currentItem == NavItem.map,
                onTap: () => _navigateTo(context, NavItem.map),
              ),
              _NavItemWidget(
                item: NavItem.crew,
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: 'Crews',
                isActive: currentItem == NavItem.crew,
                onTap: () => _navigateTo(context, NavItem.crew),
              ),
              _NavItemWidget(
                item: NavItem.events,
                icon: Icons.event_outlined,
                activeIcon: Icons.event,
                label: 'Events',
                isActive: currentItem == NavItem.events,
                onTap: () => _navigateTo(context, NavItem.events),
              ),
              _NavItemWidget(
                item: NavItem.moments,
                icon: Icons.photo_library_outlined,
                activeIcon: Icons.photo_library,
                label: 'Moments',
                isActive: currentItem == NavItem.moments,
                onTap: () => _navigateTo(context, NavItem.moments),
              ),
              _NavItemWidget(
                item: NavItem.profile,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentItem == NavItem.profile,
                onTap: () => _navigateTo(context, NavItem.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, NavItem item) {
    if (item == currentItem) return;

    final route = switch (item) {
      NavItem.map => AppRouter.map,
      NavItem.crew => AppRouter.crew,
      NavItem.events => AppRouter.events,
      NavItem.moments => AppRouter.moments,
      NavItem.profile => AppRouter.profile,
    };

    context.go(route);
  }
}

class _NavItemWidget extends StatefulWidget {

  const _NavItemWidget({
    required this.item,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final NavItem item;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: widget.isActive
              ? BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  key: ValueKey(widget.isActive),
                  color: widget.isActive ? AppColors.accent : AppColors.lightGrey,
                  size: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive ? AppColors.accent : AppColors.lightGrey,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

