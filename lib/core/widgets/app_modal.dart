import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';

class AppModal {
  const AppModal._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: DefaultTextStyle(
          style: IosDesignSystem.titleStyle,
          child: title,
        ),
        content: DefaultTextStyle(
          style: IosDesignSystem.bodyStyle.copyWith(
            color: AppColors.lightGrey,
          ),
          child: content,
        ),
        actions: actions,
      ),
    );
  }

  static Widget action({
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      isDestructiveAction: isDestructive,
      child: Text(
        label,
        style: IosDesignSystem.buttonStyle.copyWith(
          color: isDestructive ? AppColors.error : AppColors.accent,
        ),
      ),
    );
  }
}
