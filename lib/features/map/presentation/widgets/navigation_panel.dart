import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart'
    as nav_entities;
import 'package:gearhead_br/features/map/presentation/bloc/map_state.dart';

/// Painel de navegação exibido no modo Drive
/// Mostra informações da rota e instruções de direção
class NavigationPanel extends StatelessWidget {
  const NavigationPanel({
    super.key,
    required this.mapState,
    required this.onStopNavigation,
  });

  final MapState mapState;
  final VoidCallback onStopNavigation;

  @override
  @override
  Widget build(BuildContext context) {
    if (!mapState.isNavigating || mapState.navigationState == null) {
      return const SizedBox.shrink();
    }

    final navState = mapState.navigationState!;
    final currentInstruction = navState.currentInstruction;

    return Column(
      children: [
        // Painel superior - Próxima instrução
        _buildInstructionPanel(currentInstruction, navState),

        const Spacer(),

        // Painel inferior - Informações da viagem
        _buildTripInfoPanel(navState),
      ],
    );
  }

  /// Painel com a próxima instrução de navegação
  /// Estilo Waze: posicionado no topo esquerdo, mais compacto
  Widget _buildInstructionPanel(
    nav_entities.NavigationInstruction? instruction,
    nav_entities.NavigationState navState,
  ) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkGrey.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone da manobra (menor, estilo Waze)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                ),
                child: Icon(
                  _getManeuverIconData(instruction?.maneuverType ?? 'straight'),
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Distância e instrução
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDistance(navState.distanceToNextStep),
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  if (instruction != null)
                    SizedBox(
                      width: 200,
                      child: Text(
                        instruction.instruction,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna o ícone da manobra (versão simplificada para o painel compacto)
  IconData _getManeuverIconData(String maneuverType) {
    switch (maneuverType) {
      case 'turn':
      case 'turn-right':
        return Icons.turn_right_rounded;
      case 'turn-left':
        return Icons.turn_left_rounded;
      case 'slight-right':
      case 'turn-slight-right':
        return Icons.turn_slight_right_rounded;
      case 'slight-left':
      case 'turn-slight-left':
        return Icons.turn_slight_left_rounded;
      case 'sharp-right':
      case 'turn-sharp-right':
        return Icons.turn_sharp_right_rounded;
      case 'sharp-left':
      case 'turn-sharp-left':
        return Icons.turn_sharp_left_rounded;
      case 'uturn':
      case 'uturn-right':
      case 'uturn-left':
        return Icons.u_turn_right_rounded;
      case 'merge':
        return Icons.merge_rounded;
      case 'fork':
      case 'fork-right':
      case 'fork-left':
        return Icons.fork_right_rounded;
      case 'roundabout':
      case 'rotary':
        return Icons.roundabout_right_rounded;
      case 'arrive':
        return Icons.flag_rounded;
      case 'depart':
        return Icons.navigation_rounded;
      default:
        return Icons.arrow_upward_rounded;
    }
  }

  /// Painel com informações da viagem
  /// Estilo Waze: posicionado no bottom esquerdo, mais próximo do bottom
  Widget _buildTripInfoPanel(nav_entities.NavigationState navState) {
    final route = navState.route;

    return SafeArea(
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Painel de informações (esquerda)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16, bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkGrey.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tempo estimado
                  _buildInfoItem(
                    icon: Icons.access_time_rounded,
                    label: 'Tempo',
                    value: route.formattedDuration,
                  ),

                  // Separador
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.mediumGrey,
                  ),

                  // Distância total
                  _buildInfoItem(
                    icon: Icons.route_rounded,
                    label: 'Distância',
                    value: route.formattedDistance,
                  ),
                ],
              ),
            ),
          ),

          // Botão de parar navegação (direita)
          Container(
            margin: const EdgeInsets.only(right: 16, bottom: 16),
            child: _buildStopButton(),
          ),
        ],
      ),
    );
  }

  /// Item de informação (tempo/distância)
  /// Estilo Waze: mais compacto, horizontal
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.lightGrey, size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: AppColors.lightGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Botão para parar a navegação
  /// Estilo Waze: botão quadrado com X, posicionado no bottom direito
  Widget _buildStopButton() {
    return GestureDetector(
      onTap: onStopNavigation,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }


  /// Formata a distância para exibição
  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }
}

/// Botão flutuante para iniciar navegação quando há destino selecionado
/// Inclui botão de cancelar ao lado (estilo Mapbox)
class StartNavigationButton extends StatelessWidget {
  const StartNavigationButton({
    super.key,
    required this.destination,
    required this.onStartNavigation,
    required this.onCancel,
    this.isCalculating = false,
  });

  final nav_entities.NavigationDestination destination;
  final VoidCallback onStartNavigation;
  final VoidCallback onCancel;
  final bool isCalculating;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Row(
          children: [
            // Botão de cancelar (esquerda)
            GestureDetector(
              onTap: onCancel,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mediumGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botão de iniciar navegação (direita, expandido)
            Expanded(
              child: GestureDetector(
                onTap: isCalculating ? null : onStartNavigation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isCalculating
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentDark],
                          ),
                    color: isCalculating ? AppColors.darkGrey : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isCalculating ? Colors.black : AppColors.accent)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCalculating) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Calculando rota...',
                          style: GoogleFonts.rajdhani(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.navigation_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INICIAR NAVEGAÇÃO',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                destination.name,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

