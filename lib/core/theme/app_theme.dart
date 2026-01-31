import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema principal do GEARHEAD BR
/// Design dark focado na cultura automotiva noturna
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // COLOR SCHEME
      // ═══════════════════════════════════════════════════════════════════════
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.white,
        secondary: AppColors.accentLight,
        onSecondary: AppColors.black,
        surface: AppColors.darkGrey,
        onSurface: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // SCAFFOLD
      // ═══════════════════════════════════════════════════════════════════════
      scaffoldBackgroundColor: AppColors.black,
      
      // ═══════════════════════════════════════════════════════════════════════
      // APP BAR
      // ═══════════════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // TEXT THEME
      // ═══════════════════════════════════════════════════════════════════════
      textTheme: TextTheme(
        // Display
        displayLarge: GoogleFonts.orbitron(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        
        // Headlines
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        
        // Titles
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
        
        // Body
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.white,
        ),
        bodySmall: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.lightGrey,
        ),
        
        // Labels
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.rajdhani(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.lightGrey,
          letterSpacing: 0.5,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // INPUT DECORATION
      // ═══════════════════════════════════════════════════════════════════════
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        
        labelStyle: GoogleFonts.rajdhani(
          color: AppColors.lightGrey,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.rajdhani(
          color: AppColors.lightGrey,
          fontSize: 16,
        ),
        errorStyle: GoogleFonts.rajdhani(
          color: AppColors.error,
          fontSize: 12,
        ),
        
        prefixIconColor: AppColors.lightGrey,
        suffixIconColor: AppColors.lightGrey,
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // ELEVATED BUTTON
      // ═══════════════════════════════════════════════════════════════════════
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // OUTLINED BUTTON
      // ═══════════════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: const BorderSide(color: AppColors.mediumGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // TEXT BUTTON
      // ═══════════════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // CARD
      // ═══════════════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        color: AppColors.darkGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.mediumGrey),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // BOTTOM NAVIGATION BAR
      // ═══════════════════════════════════════════════════════════════════════
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGrey,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.lightGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // DIVIDER
      // ═══════════════════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.mediumGrey,
        thickness: 1,
        space: 1,
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // ICON
      // ═══════════════════════════════════════════════════════════════════════
      iconTheme: const IconThemeData(
        color: AppColors.white,
        size: 24,
      ),
      
      // ═══════════════════════════════════════════════════════════════════════
      // SNACKBAR
      // ═══════════════════════════════════════════════════════════════════════
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGrey,
        contentTextStyle: GoogleFonts.rajdhani(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
