import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';
import 'package:gearhead_br/features/garage/presentation/bloc/garage_bloc.dart';

/// Dialog para adicionar/editar veículo
class VehicleFormDialog extends StatefulWidget {

  const VehicleFormDialog({
    super.key,
    this.vehicle,
  });
  final VehicleEntity? vehicle;

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
  String? _selectedImageUrl;

  bool get isEditing => widget.vehicle != null;
  
  String? get _currentImageUrl => _selectedImageUrl ?? 
      (widget.vehicle?.photoUrls.isNotEmpty == true 
          ? widget.vehicle!.photoUrls.first 
          : null);

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
    _selectedImageUrl = widget.vehicle?.photoUrls.isNotEmpty == true
        ? widget.vehicle!.photoUrls.first
        : null;
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

                // Seção de Imagem
                Text(
                  'Foto do Veículo',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mediumGrey,
                        width: 1,
                      ),
                    ),
                    child: _currentImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: _currentImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.mediumGrey,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColors.mediumGrey,
                                    child: const Center(
                                      child: Icon(
                                        Icons.directions_car_rounded,
                                        color: AppColors.lightGrey,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
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
                                            Icons.camera_alt_rounded,
                                            color: AppColors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'ALTERAR FOTO',
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
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: AppColors.lightGrey,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Adicionar foto',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 14,
                                    color: AppColors.lightGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toque para selecionar',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 12,
                                    color: AppColors.mediumGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Formulário
                NeonTextField(
                  controller: _brandController,
                  labelText: 'Marca *',
                  hintText: 'Ex: Chevrolet, Volkswagen',
                  prefixIcon: Icons.business_rounded,
                ),

                const SizedBox(height: 16),

                NeonTextField(
                  controller: _modelController,
                  labelText: 'Modelo *',
                  hintText: 'Ex: Opala, Fusca, Civic',
                  prefixIcon: Icons.directions_car_rounded,
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeonTextField(
                        controller: _colorController,
                        labelText: 'Cor',
                        hintText: 'Preto',
                        prefixIcon: Icons.palette_rounded,
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
      photoUrls: _selectedImageUrl != null ? [_selectedImageUrl!] : 
          (widget.vehicle?.photoUrls ?? []),
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

  void _pickImage() {
    // TODO: Implementar seleção de imagem com image_picker
    // Por enquanto, mostra um dialog informando que será implementado
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Selecionar Foto',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Funcionalidade de upload de foto será implementada em breve. Por enquanto, você pode usar uma URL de imagem.',
          style: GoogleFonts.rajdhani(
            color: AppColors.lightGrey,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.rajdhani(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showImageUrlDialog();
            },
            child: Text(
              'Usar URL',
              style: GoogleFonts.rajdhani(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageUrlDialog() {
    final controller = TextEditingController(text: _currentImageUrl ?? '');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'URL da Imagem',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.rajdhani(
            color: AppColors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Cole a URL da imagem aqui',
            hintStyle: GoogleFonts.rajdhani(
              color: AppColors.lightGrey,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.mediumGrey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.accent,
              ),
            ),
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
              setState(() {
                _selectedImageUrl = controller.text.trim().isNotEmpty
                    ? controller.text.trim()
                    : null;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Salvar',
              style: GoogleFonts.rajdhani(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
