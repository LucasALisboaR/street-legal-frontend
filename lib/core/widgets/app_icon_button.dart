import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isAccent = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isAccent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = isAccent
        ? AppColors.accent
        : AppColors.darkGrey.withOpacity(0.9);
    final borderColor = isAccent ? AppColors.accentDark : AppColors.mediumGrey;
    final iconColor = isAccent ? AppColors.white : AppColors.white;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: IosDesignSystem.fastAnimation,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(IosDesignSystem.radiusMedium),
          border: Border.all(color: borderColor),
          boxShadow: IosDesignSystem.softShadow,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
