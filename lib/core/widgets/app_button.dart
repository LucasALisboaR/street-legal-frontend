import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = 52,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double height;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isActive = isEnabled && !isLoading;
    final backgroundColor = _resolveBackground(isActive);
    final borderColor = _resolveBorder(isActive);
    final foregroundColor = _resolveForeground(isActive);

    final buttonChild = AnimatedContainer(
      duration: IosDesignSystem.fastAnimation,
      height: height,
      padding: IosDesignSystem.controlPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(IosDesignSystem.radiusLarge),
        border: Border.all(color: borderColor),
        boxShadow: isActive ? IosDesignSystem.softShadow : null,
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foregroundColor, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: IosDesignSystem.buttonStyle.copyWith(
                        color: foregroundColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isActive ? onPressed : null,
        child: buttonChild,
      ),
    );
  }

  Color _resolveBackground(bool isActive) {
    if (!isActive) {
      return AppColors.mediumGrey;
    }
    return switch (variant) {
      AppButtonVariant.primary => AppColors.accent,
      AppButtonVariant.secondary => AppColors.darkGrey,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.destructive => AppColors.error,
    };
  }

  Color _resolveBorder(bool isActive) {
    if (!isActive) {
      return AppColors.mediumGrey;
    }
    return switch (variant) {
      AppButtonVariant.primary => AppColors.accentDark,
      AppButtonVariant.secondary => AppColors.mediumGrey,
      AppButtonVariant.ghost => AppColors.mediumGrey,
      AppButtonVariant.destructive => AppColors.error,
    };
  }

  Color _resolveForeground(bool isActive) {
    if (!isActive) {
      return AppColors.lightGrey;
    }
    return switch (variant) {
      AppButtonVariant.primary => AppColors.white,
      AppButtonVariant.secondary => AppColors.white,
      AppButtonVariant.ghost => AppColors.accent,
      AppButtonVariant.destructive => AppColors.white,
    };
  }
}
