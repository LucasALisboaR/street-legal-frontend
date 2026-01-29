import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';

/// Tipo de botão social
enum SocialButtonType {
  google,
  apple,
  facebook,
}

/// Botão estilizado para login social
class SocialLoginButton extends StatefulWidget {

  const SocialLoginButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
  });
  final SocialButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final config = _getButtonConfig();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: config.borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: config.glowColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            config.textColor,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          config.icon,
                          color: config.iconColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          config.label,
                          style: TextStyle(
                            color: config.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  _SocialButtonConfig _getButtonConfig() {
    switch (widget.type) {
      case SocialButtonType.google:
        return _SocialButtonConfig(
          icon: Icons.g_mobiledata_rounded,
          label: 'Entrar com Google',
          backgroundColor: AppColors.darkGrey,
          borderColor: AppColors.mediumGrey,
          iconColor: AppColors.google,
          textColor: AppColors.white,
          glowColor: AppColors.google,
        );
      case SocialButtonType.apple:
        return _SocialButtonConfig(
          icon: Icons.apple,
          label: 'Entrar com Apple',
          backgroundColor: AppColors.white,
          borderColor: AppColors.white,
          iconColor: AppColors.black,
          textColor: AppColors.black,
          glowColor: AppColors.white,
        );
      case SocialButtonType.facebook:
        return _SocialButtonConfig(
          icon: Icons.facebook,
          label: 'Entrar com Facebook',
          backgroundColor: AppColors.facebook,
          borderColor: AppColors.facebook,
          iconColor: AppColors.white,
          textColor: AppColors.white,
          glowColor: AppColors.facebook,
        );
    }
  }
}

class _SocialButtonConfig {

  const _SocialButtonConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.glowColor,
  });
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color glowColor;
}

