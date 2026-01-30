import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';

/// Widget que anima o movimento do carro no mapa
/// Interpola suavemente entre posições e rotaciona baseado no heading
class AnimatedCarMarker extends StatefulWidget {
  final Stream<Position> positionStream;
  final double size;
  final Duration animationDuration;

  const AnimatedCarMarker({
    super.key,
    required this.positionStream,
    this.size = 40,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCarMarker> createState() => _AnimatedCarMarkerState();
  
  /// Acessa o state para obter o controller e o marker
  static _AnimatedCarMarkerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AnimatedCarMarkerState>();
  }
}

class _AnimatedCarMarkerState extends State<AnimatedCarMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Tween<LatLng>? _positionTween;
  Tween<double>? _rotationTween;

  LatLng? _currentPosition;
  LatLng? _targetPosition;
  double _currentHeading = 0.0;
  double _targetHeading = 0.0;
  StreamSubscription<Position>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Escuta o stream de posições
    _subscription = widget.positionStream.listen(_onPositionUpdate);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Calcula o heading (direção) entre duas coordenadas
  double _calculateHeading(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var heading = math.atan2(y, x);
    heading = heading * 180 / math.pi;
    heading = (heading + 360) % 360; // Normaliza para 0-360

    return heading;
  }

  /// Normaliza o ângulo para tratar o ciclo 359° -> 0°
  double _normalizeAngle(double angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
  }

  /// Calcula a menor rotação entre dois ângulos
  double _shortestRotation(double from, double to) {
    from = _normalizeAngle(from);
    to = _normalizeAngle(to);

    var diff = to - from;

    // Trata o caso de passar pelo zero (359° -> 0°)
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    return from + diff;
  }

  /// Tween customizado para LatLng
  LatLng _lerpLatLng(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  /// Callback quando uma nova posição é recebida
  void _onPositionUpdate(Position position) {
    final newPosition = LatLng(position.latitude, position.longitude);
    final newHeading = position.heading.isFinite && position.heading > 0
        ? position.heading
        : (_currentPosition != null
            ? _calculateHeading(_currentPosition!, newPosition)
            : _currentHeading);

    setState(() {
      if (_currentPosition == null) {
        // Primeira posição - não anima
        _currentPosition = newPosition;
        _targetPosition = newPosition;
        _currentHeading = newHeading;
        _targetHeading = newHeading;
        return;
      }

      // Atualiza posição alvo
      _targetPosition = newPosition;
      _targetHeading = newHeading;

      // Atualiza tween de posição
      _positionTween = Tween<LatLng>(
        begin: _currentPosition!,
        end: _targetPosition!,
      );

      // Atualiza tween de rotação
      final targetRotation = _shortestRotation(_currentHeading, _targetHeading);
      _rotationTween = Tween<double>(
        begin: _currentHeading,
        end: targetRotation,
      );

      // Inicia animação
      _controller.forward(from: 0.0);
      
      // Notifica mudança para atualizar o marker
      notifyUpdate();
    });
  }

  /// Retorna o Marker animado atual
  Marker? getCurrentMarker() {
    if (_currentPosition == null) {
      return null;
    }

    // Interpola posição atual
    final animatedPosition = _controller.isAnimating && 
                             _positionTween != null &&
                             _positionTween!.begin != null &&
                             _positionTween!.end != null
        ? _lerpLatLng(_positionTween!.begin!, _positionTween!.end!, _controller.value)
        : _currentPosition!;

    // Interpola rotação atual
    final animatedHeading = _controller.isAnimating && 
                           _rotationTween != null &&
                           _rotationTween!.begin != null &&
                           _rotationTween!.end != null
        ? _rotationTween!.begin! + (_rotationTween!.end! - _rotationTween!.begin!) * _controller.value
        : _currentHeading;

    // Atualiza posição e heading atuais quando animação termina
    if (!_controller.isAnimating && _targetPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentPosition = _targetPosition;
            _currentHeading = _targetHeading;
          });
        }
      });
    }

    return Marker(
      point: animatedPosition,
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: animatedHeading * math.pi / 180,
        child: _CarIcon(
          size: widget.size,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Este widget não renderiza nada diretamente
    // O Marker é obtido via getCurrentMarker()
    // O AnimatedBuilder garante que getCurrentMarker() seja chamado a cada frame
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Força rebuild quando animação muda
        // Isso garante que o StreamBuilder no MapPage seja notificado
        return const SizedBox.shrink();
      },
    );
  }
  
  /// Notifica mudanças para forçar rebuild no StreamBuilder
  void notifyUpdate() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// Widget do ícone do carro com efeito de glow
class _CarIcon extends StatelessWidget {
  final double size;

  const _CarIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.6),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Ícone do carro
          Icon(
            Icons.directions_car,
            color: AppColors.accent,
            size: size * 0.7,
          ),
        ],
      ),
    );
  }
}

