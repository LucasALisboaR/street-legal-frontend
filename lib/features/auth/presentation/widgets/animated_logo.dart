import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';

/// Logo animada do GEARHEAD BR com efeito neon
class AnimatedLogo extends StatefulWidget {

  const AnimatedLogo({
    super.key,
    this.size = 120,
  });
  final double size;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.5 * _glowAnimation.value),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.darkGrey,
                    AppColors.black,
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent.withOpacity(_glowAnimation.value),
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone de engrenagem/velocímetro
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          AppColors.accentLight,
                        ],
                      ).createShader(bounds),
                      child: Icon(
                        Icons.speed_rounded,
                        size: widget.size * 0.4,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Texto GH
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.white,
                          AppColors.accent,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'GH',
                        style: GoogleFonts.orbitron(
                          fontSize: widget.size * 0.2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

