import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(IosDesignSystem.radiusLarge),
      child: BackdropFilter(
        filter: IosDesignSystem.modalBlur,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.darkGrey.withOpacity(0.9),
            borderRadius: BorderRadius.circular(IosDesignSystem.radiusLarge),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: IosDesignSystem.cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
