import 'package:flutter/material.dart';

/// Paleta de cores do GEARHEAD BR
/// Inspirada na cultura automotiva noturna com toques neon
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // CORES PRIMÁRIAS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Preto profundo - Background principal
  static const Color black = Color(0xFF0D0D0D);
  
  /// Cinza escuro - Superfícies e cards
  static const Color darkGrey = Color(0xFF1A1A1A);
  
  /// Cinza médio - Bordas e divisores
  static const Color mediumGrey = Color(0xFF2D2D2D);
  
  /// Cinza claro - Textos secundários
  static const Color lightGrey = Color(0xFF757575);
  
  /// Branco - Textos principais
  static const Color white = Color(0xFFFAFAFA);

  // ═══════════════════════════════════════════════════════════════════════════
  // CORES DE DESTAQUE (NEON)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Laranja vibrante - Cor de destaque principal
  static const Color accent = Color(0xFFFF4500);
  
  /// Laranja escuro - Hover/Pressed states
  static const Color accentDark = Color(0xFFCC3700);
  
  /// Laranja claro - Highlights
  static const Color accentLight = Color(0xFFFF6B33);

  // ═══════════════════════════════════════════════════════════════════════════
  // CORES DE STATUS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Verde - Sucesso
  static const Color success = Color(0xFF00E676);
  
  /// Vermelho - Erro
  static const Color error = Color(0xFFFF1744);
  
  /// Amarelo - Aviso
  static const Color warning = Color(0xFFFFEA00);
  
  /// Azul - Informação
  static const Color info = Color(0xFF00B0FF);

  // ═══════════════════════════════════════════════════════════════════════════
  // CORES SOCIAIS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Google
  static const Color google = Color(0xFFDB4437);
  
  /// Apple
  static const Color apple = Color(0xFFFFFFFF);
  
  /// Facebook
  static const Color facebook = Color(0xFF1877F2);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Gradiente principal do app
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  /// Gradiente de fundo
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkGrey, black],
  );

  /// Gradiente neon glow
  static const RadialGradient neonGlow = RadialGradient(
    colors: [
      Color(0x33FF4500),
      Color(0x00FF4500),
    ],
  );
}

