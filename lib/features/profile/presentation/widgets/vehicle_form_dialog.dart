import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/garage_bloc.dart';

/// Dialog para adicionar/editar veículo
class VehicleFormDialog extends StatefulWidget {
  final VehicleEntity? vehicle;

  const VehicleFormDialog({
    super.key,
    this.vehicle,
  });

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _nicknameController;
  late TextEditingController _colorController;
  late TextEditingController _plateController;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _nicknameController = TextEditingController(
      text: widget.vehicle?.nickname ?? '',
    );
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _plateController = TextEditingController(
      text: widget.vehicle?.licensePlate ?? '',
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _nicknameController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mediumGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Título
                Text(
                  isEditing ? 'EDITAR VEÍCULO' : 'NOVO VEÍCULO',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isEditing
                      ? 'Atualize as informações do seu veículo'
                      : 'Adicione um novo veículo à sua garagem',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                ),

                const SizedBox(height: 32),

                // Formulário
                NeonTextField(
                  controller: _brandController,
                  labelText: 'Marca *',
                  hintText: 'Ex: Chevrolet, Volkswagen',
                  prefixIcon: Icons.business_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                NeonTextField(
                  controller: _modelController,
                  labelText: 'Modelo *',
                  hintText: 'Ex: Opala, Fusca, Civic',
                  prefixIcon: Icons.directions_car_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: NeonTextField(
                        controller: _yearController,
                        labelText: 'Ano *',
                        hintText: '1988',
                        prefixIcon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeonTextField(
                        controller: _colorController,
                        labelText: 'Cor',
                        hintText: 'Preto',
                        prefixIcon: Icons.palette_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                NeonTextField(
                  controller: _nicknameController,
                  labelText: 'Apelido',
                  hintText: 'Ex: Opalão, Fuscão',
                  prefixIcon: Icons.favorite_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                NeonTextField(
                  controller: _plateController,
                  labelText: 'Placa',
                  hintText: 'ABC-1234',
                  prefixIcon: Icons.pin_rounded,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 32),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.mediumGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: NeonButton(
                        text: isEditing ? 'SALVAR' : 'ADICIONAR',
                        icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    // Validação básica
    if (_brandController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha os campos obrigatórios'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ano inválido'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final vehicle = VehicleEntity(
      id: widget.vehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user-1', // TODO: Pegar do AuthBloc
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      nickname: _nicknameController.text.trim().isNotEmpty
          ? _nicknameController.text.trim()
          : null,
      color: _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      licensePlate: _plateController.text.trim().isNotEmpty
          ? _plateController.text.trim()
          : null,
      createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      context.read<GarageBloc>().add(GarageVehicleUpdated(vehicle));
    } else {
      context.read<GarageBloc>().add(GarageVehicleAdded(vehicle));
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Veículo atualizado!' : 'Veículo adicionado!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

