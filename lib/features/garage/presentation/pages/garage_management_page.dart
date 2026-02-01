import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';
import 'package:gearhead_br/features/garage/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/garage/presentation/widgets/vehicle_form_dialog.dart';

/// Página de Gestão de Garagem
/// Exibe todos os veículos cadastrados com opções de editar, excluir e criar novo
class GarageManagementPage extends StatelessWidget {
  const GarageManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GarageBloc()..add(const GarageLoadRequested()),
      child: const _GarageManagementView(),
    );
  }
}

class _GarageManagementView extends StatelessWidget {
  const _GarageManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.white,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MINHA GARAGEM',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<GarageBloc, GarageState>(
        builder: (context, state) {
          if (state.status == GarageStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            );
          }

          if (state.vehicles.isEmpty) {
            return _EmptyGarage(
              onAdd: () => _showAddVehicleDialog(context),
            );
          }

          return Column(
            children: [
              // Contador de veículos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.vehicleCount} ${state.vehicleCount == 1 ? 'veículo' : 'veículos'}',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                            const SizedBox(width: 6),
                            Text(
                              'ADICIONAR',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de veículos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = state.vehicles[index];
                    final isActive = vehicle.id == state.activeVehicleId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _VehicleCard(
                        vehicle: vehicle,
                        isActive: isActive,
                        onTap: () => context
                            .read<GarageBloc>()
                            .add(GarageActiveVehicleChanged(vehicle.id)),
                        onEdit: () => _showEditVehicleDialog(context, vehicle),
                        onDelete: () => _showDeleteConfirmation(context, vehicle),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showModalBottomSheet<void>(
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
    showModalBottomSheet<void>(
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
    showDialog<void>(
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
  const _EmptyGarage({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'Sua garagem está vazia',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
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
          const SizedBox(height: 24),
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
  const _VehicleCard({
    required this.vehicle,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final VehicleEntity vehicle;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final vehicleImageUrl = vehicle.photoUrls.isNotEmpty
        ? vehicle.photoUrls.first
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.mediumGrey,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Foto do veículo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.black,
                child: vehicleImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: vehicleImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.mediumGrey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.mediumGrey,
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: isActive ? AppColors.accent : AppColors.lightGrey,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.mediumGrey,
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: isActive ? AppColors.accent : AppColors.lightGrey,
                          size: 40,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Informações do veículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (vehicle.nickname != null) ...[
                        Text(
                          vehicle.nickname!,
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ATIVO',
                            style: GoogleFonts.orbitron(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.year}${vehicle.color != null ? ' • ${vehicle.color}' : ''}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Botões de ação
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: AppColors.lightGrey,
                  onTap: onEdit,
                ),
                const SizedBox(height: 8),
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
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
