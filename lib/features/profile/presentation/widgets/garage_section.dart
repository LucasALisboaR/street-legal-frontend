import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/profile/presentation/widgets/vehicle_form_dialog.dart';

/// Seção de Garagem dentro do Perfil
class GarageSection extends StatelessWidget {
  const GarageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.garage_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MINHA GARAGEM',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${state.vehicleCount}',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showAddVehicleDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de veículos
            if (state.status == GarageStatus.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                ),
              )
            else if (state.vehicles.isEmpty)
              _EmptyGarage(onAdd: () => _showAddVehicleDialog(context))
            else
              SizedBox(
                height: 145,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = state.vehicles[index];
                    final isActive = vehicle.id == state.activeVehicleId;
                    return _VehicleCard(
                      vehicle: vehicle,
                      isActive: isActive,
                      onTap: () => context
                          .read<GarageBloc>()
                          .add(GarageActiveVehicleChanged(vehicle.id)),
                      onEdit: () => _showEditVehicleDialog(context, vehicle),
                      onDelete: () => _showDeleteConfirmation(context, vehicle),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GarageBloc>(),
        child: const VehicleFormDialog(),
      ),
    );
  }

  void _showEditVehicleDialog(BuildContext context, VehicleEntity vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GarageBloc>(),
        child: VehicleFormDialog(vehicle: vehicle),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Remover veículo?',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover "${vehicle.displayName}" da sua garagem?',
          style: GoogleFonts.rajdhani(
            color: AppColors.lightGrey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.rajdhani(
                color: AppColors.lightGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<GarageBloc>().add(GarageVehicleDeleted(vehicle.id));
              Navigator.pop(context);
            },
            child: Text(
              'Remover',
              style: GoogleFonts.rajdhani(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGarage extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyGarage({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGrey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'Sua garagem está vazia',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro veículo',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar veículo',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 155,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.mediumGrey,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Ícone + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withOpacity(0.2)
                        : AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: isActive ? AppColors.accent : AppColors.lightGrey,
                    size: 20,
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ATIVO',
                      style: GoogleFonts.orbitron(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Info do veículo
            if (vehicle.nickname != null)
              Text(
                vehicle.nickname!,
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${vehicle.year}${vehicle.color != null ? ' • ${vehicle.color}' : ''}',
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: AppColors.lightGrey,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Botões de ação
            Row(
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.lightGrey,
                  onTap: onEdit,
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: color,
          size: 12,
        ),
      ),
    );
  }
}
