import 'package:flutter/material.dart';
import 'package:gearhead_br/core/widgets/app_button.dart';

/// Botão com efeito neon/glow animado
class NeonButton extends StatefulWidget {

  const NeonButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height = 56,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
      animation: _pulseAnimation,
      builder: (context, child) => SizedBox(
        width: widget.width,
        child: child,
      ),
      child: AppButton(
        label: widget.text,
        icon: widget.icon,
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
        isEnabled: widget.isEnabled,
        height: widget.height,
      ),
    );
  }
}
