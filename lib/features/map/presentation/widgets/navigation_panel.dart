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
  Widget _buildInstructionPanel(
    nav_entities.NavigationInstruction? instruction,
    nav_entities.NavigationState navState,
  ) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGrey.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Distância até a próxima manobra
            Row(
              children: [
                _buildManeuverIcon(instruction?.maneuverType ?? 'straight'),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDistance(navState.distanceToNextStep),
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      if (instruction != null)
                        Text(
                          instruction.instruction,
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Indicador de recálculo de rota
            if (mapState.isCalculatingRoute) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recalculando rota...',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ],

            // Aviso de fora da rota
            if (navState.isOffRoute) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você saiu da rota',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Painel com informações da viagem
  Widget _buildTripInfoPanel(nav_entities.NavigationState navState) {
    final route = navState.route;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGrey.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tempo estimado
            Expanded(
              child: _buildInfoItem(
                icon: Icons.access_time_rounded,
                label: 'Tempo',
                value: route.formattedDuration,
              ),
            ),

            // Separador
            Container(
              width: 1,
              height: 40,
              color: AppColors.mediumGrey,
            ),

            // Distância total
            Expanded(
              child: _buildInfoItem(
                icon: Icons.route_rounded,
                label: 'Distância',
                value: route.formattedDistance,
              ),
            ),

            // Separador
            Container(
              width: 1,
              height: 40,
              color: AppColors.mediumGrey,
            ),

            // Botão de parar navegação
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildStopButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Item de informação (tempo/distância)
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.lightGrey, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.lightGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  /// Botão para parar a navegação
  Widget _buildStopButton() {
    return GestureDetector(
      onTap: onStopNavigation,
      child: Container(
        width: 50,
        height: 50,
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
          size: 28,
        ),
      ),
    );
  }

  /// Ícone da manobra baseado no tipo
  Widget _buildManeuverIcon(String maneuverType) {
    IconData icon;
    switch (maneuverType) {
      case 'turn':
      case 'turn-right':
        icon = Icons.turn_right_rounded;
        break;
      case 'turn-left':
        icon = Icons.turn_left_rounded;
        break;
      case 'slight-right':
      case 'turn-slight-right':
        icon = Icons.turn_slight_right_rounded;
        break;
      case 'slight-left':
      case 'turn-slight-left':
        icon = Icons.turn_slight_left_rounded;
        break;
      case 'sharp-right':
      case 'turn-sharp-right':
        icon = Icons.turn_sharp_right_rounded;
        break;
      case 'sharp-left':
      case 'turn-sharp-left':
        icon = Icons.turn_sharp_left_rounded;
        break;
      case 'uturn':
      case 'uturn-right':
      case 'uturn-left':
        icon = Icons.u_turn_right_rounded;
        break;
      case 'merge':
        icon = Icons.merge_rounded;
        break;
      case 'fork':
      case 'fork-right':
      case 'fork-left':
        icon = Icons.fork_right_rounded;
        break;
      case 'roundabout':
      case 'rotary':
        icon = Icons.roundabout_right_rounded;
        break;
      case 'arrive':
        icon = Icons.flag_rounded;
        break;
      case 'depart':
        icon = Icons.navigation_rounded;
        break;
      default:
        icon = Icons.arrow_upward_rounded;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Icon(
        icon,
        color: AppColors.accent,
        size: 32,
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
class StartNavigationButton extends StatelessWidget {
  const StartNavigationButton({
    super.key,
    required this.destination,
    required this.onStartNavigation,
    this.isCalculating = false,
  });

  final nav_entities.NavigationDestination destination;
  final VoidCallback onStartNavigation;
  final bool isCalculating;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
                  Column(
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

