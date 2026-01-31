import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';

class AppBottomSheet {
  const AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (sheetContext) {
        final sheetContent = builder(sheetContext);
        return _SheetContainer(child: sheetContent);
      },
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(IosDesignSystem.radiusXLarge),
      ),
      child: BackdropFilter(
        filter: IosDesignSystem.modalBlur,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkGrey.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(IosDesignSystem.radiusXLarge),
            ),
            border: Border.all(color: AppColors.mediumGrey),
          ),
          child: child,
        ),
      ),
    );
  }
}
