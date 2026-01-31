import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design System com estética iOS para o GEARHEAD BR.
/// Mantém a paleta atual e ajusta tipografia, spacing e radius.
class IosDesignSystem {
  IosDesignSystem._();

  // ─────────────────────────────────────────────────────────────────────────
  // DIMENSIONS
  // ─────────────────────────────────────────────────────────────────────────
  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;
  static const double radiusXLarge = 26;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets controlPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 320);

  // ─────────────────────────────────────────────────────────────────────────
  // SHADOWS & BLUR
  // ─────────────────────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static ImageFilter get modalBlur => ImageFilter.blur(sigmaX: 20, sigmaY: 20);

  // ─────────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────────────────────────────────────────
  static TextStyle get headlineStyle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get titleStyle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      );

  static TextStyle get captionStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.lightGrey,
      );

  static TextStyle get buttonStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.4,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // CUPERTINO THEME
  // ─────────────────────────────────────────────────────────────────────────
  static CupertinoThemeData get cupertinoTheme => CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accent,
        primaryContrastingColor: AppColors.white,
        scaffoldBackgroundColor: AppColors.black,
        barBackgroundColor: AppColors.darkGrey.withOpacity(0.94),
        textTheme: CupertinoTextThemeData(
          textStyle: bodyStyle,
          navTitleTextStyle: titleStyle,
          navLargeTitleTextStyle: headlineStyle,
          pickerTextStyle: bodyStyle,
          tabLabelTextStyle: captionStyle,
        ),
      );
}
