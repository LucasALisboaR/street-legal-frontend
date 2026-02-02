import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/garage/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/profile/data/models/user_profile_model.dart';
import 'package:gearhead_br/features/profile/domain/entities/badge_entity.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/profile_bloc.dart';

/// Página de Perfil do usuário
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
        ),
        BlocProvider(
          create: (context) => GarageBloc()..add(const GarageLoadRequested()),
        ),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        // Só escutar mudanças relevantes
        // Ignorar mudanças de initial -> loading (carregamento inicial)
        if (previous.status == ProfileStatus.initial && 
            current.status == ProfileStatus.loading) {
          return false;
        }
        
        // Escutar mudanças de status que indicam operações (upload/update)
        if (previous.status != current.status) {
          // Escutar apenas falhas com mensagem ou sucessos após operações
          if (current.status == ProfileStatus.failure) {
            return current.errorMessage != null && current.errorMessage!.isNotEmpty;
          }
          // Escutar sucesso apenas se veio de uma operação (não do carregamento inicial)
          if (current.status == ProfileStatus.success) {
            return previous.status == ProfileStatus.updatingProfile ||
                   previous.status == ProfileStatus.uploadingPicture ||
                   previous.status == ProfileStatus.uploadingBanner;
          }
        }
        return false;
      },
      listener: (context, state) {
        // Tratar erros
        if (state.status == ProfileStatus.failure && 
            state.errorMessage != null && 
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(state.errorMessage!),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        // Tratar sucesso de operações
        if (state.status == ProfileStatus.success && state.profile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Perfil atualizado com sucesso!')),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PERFIL',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    Row(
                      children: [
                        _IconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _IconButton(
                          icon: Icons.logout_rounded,
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: ListView(
                  children: const [
                    // Card de Identidade do Usuário
                    _UserInfoSection(),

                    SizedBox(height: 24),

                    // Veículo Ativo Destacado
                    _ActiveVehicleSection(),
                  ],
                ),
              ),

              // Bottom Navigation
              const BottomNavBar(currentItem: NavItem.profile),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final authService = getIt<AuthService>();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sair do app?',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você será desconectado da sua conta.',
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
              Navigator.pop(context);
              authService.logout();
            },
            child: Text(
              'Sair',
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

class _IconButton extends StatelessWidget {

  const _IconButton({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGrey,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ),
          );
        }

        if (state.status == ProfileStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Erro ao carregar perfil',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.lightGrey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final profile = state.profile;
        if (profile == null) {
          return const SizedBox.shrink();
        }

        final userName = profile.name ?? 'Usuário';
        final userHandle = profile.crew?.tag != null
            ? '@${profile.crew!.tag}'
            : profile.id.substring(0, profile.id.length > 8 ? 8 : profile.id.length);
        final profilePhotoUrl = profile.avatarUrl;
        final bio = profile.bio;
        final stats = profile.stats;
        // TODO: Adicionar campo bannerUrl no UserProfileModel quando disponível no backend
        final String? backgroundImageUrl = null;

        return _buildUserInfo(
          context: context,
          userName: userName,
          userHandle: userHandle,
          bio: bio,
          stats: stats,
          profilePhotoUrl: profilePhotoUrl,
          backgroundImageUrl: backgroundImageUrl,
        );
      },
    );
  }

  Widget _buildUserInfo({
    required BuildContext context,
    required String userName,
    required String userHandle,
    String? bio,
    UserProfileStats? stats,
    String? profilePhotoUrl,
    String? backgroundImageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner de fundo (atrás do card)
          if (backgroundImageUrl != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.darkGrey.withOpacity(0.7),
                        BlendMode.darken,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: backgroundImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Botão de editar banner
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showEditBannerDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.accent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Card de identidade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.darkGrey.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.mediumGrey,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto de perfil circular com borda colorida
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                                child: profilePhotoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: profilePhotoUrl,
                                cacheKey: '${profilePhotoUrl}_${DateTime.now().millisecondsSinceEpoch}',
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
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accentDark,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userName
                                          .split(' ')
                                          .map((n) => n.isNotEmpty ? n[0] : '')
                                          .join('')
                                          .toUpperCase(),
                                      style: GoogleFonts.orbitron(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accentDark,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    userName
                                        .split(' ')
                                        .map((n) => n.isNotEmpty ? n[0] : '')
                                        .join('')
                                        .toUpperCase(),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Botão de editar foto
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: GestureDetector(
                        onTap: () => _showEditProfileDialog(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.darkGrey,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nome do usuário
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(context, userName, bio),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.lightGrey,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bio do usuário (logo abaixo do nome)
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.mediumGrey.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        bio,
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.lightGrey,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],

                // Status do usuário (carros, eventos, conquistas)
                if (stats != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(
                        label: 'Carros',
                        value: stats.totalCars,
                      ),
                      _StatusChip(
                        label: 'Eventos',
                        value: stats.totalEvents,
                      ),
                      _StatusChip(
                        label: 'Badges',
                        value: stats.totalBadges,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // Handle do usuário
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    userHandle,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chip de status do usuário
  Widget _StatusChip({
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 9,
                  color: AppColors.lightGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final imagePicker = ImagePicker();
    
    // Mostrar opções: Galeria ou Câmera
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.accent),
              title: Text(
                'Galeria',
                style: GoogleFonts.rajdhani(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accent),
              title: Text(
                'Câmera',
                style: GoogleFonts.rajdhani(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
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
        ],
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null && context.mounted) {
        context.read<ProfileBloc>().add(
              ProfilePictureUploadRequested(pickedFile.path),
            );
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Erro ao selecionar imagem';
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('cancel') || errorString.contains('canceled')) {
          // Usuário cancelou, não mostrar erro
          return;
        } else if (errorString.contains('permission') || errorString.contains('denied')) {
          errorMessage = 'Permissão de acesso negada. Verifique as configurações do app.';
        } else if (errorString.contains('channel') || errorString.contains('connection')) {
          errorMessage = 'Erro de comunicação. Tente reiniciar o app.';
        } else {
          errorMessage = 'Erro ao acessar a galeria/câmera. Tente novamente.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showEditBannerDialog(BuildContext context) async {
    final imagePicker = ImagePicker();
    
    // Mostrar opções: Galeria ou Câmera
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Selecionar Banner',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.accent),
              title: Text(
                'Galeria',
                style: GoogleFonts.rajdhani(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accent),
              title: Text(
                'Câmera',
                style: GoogleFonts.rajdhani(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
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
        ],
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null && context.mounted) {
        context.read<ProfileBloc>().add(
              ProfileBannerUploadRequested(pickedFile.path),
            );
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Erro ao selecionar imagem';
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('cancel') || errorString.contains('canceled')) {
          // Usuário cancelou, não mostrar erro
          return;
        } else if (errorString.contains('permission') || errorString.contains('denied')) {
          errorMessage = 'Permissão de acesso negada. Verifique as configurações do app.';
        } else if (errorString.contains('channel') || errorString.contains('connection')) {
          errorMessage = 'Erro de comunicação. Tente reiniciar o app.';
        } else {
          errorMessage = 'Erro ao acessar a galeria/câmera. Tente novamente.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName, String? currentBio) {
    final nameController = TextEditingController(text: currentName);
    final bioController = TextEditingController(text: currentBio ?? '');
    final profileBloc = context.read<ProfileBloc>();
    
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Não permitir fechar clicando fora durante loading
      builder: (dialogContext) => BlocProvider.value(
        value: profileBloc,
        child: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) {
            // Escutar apenas mudanças de updatingProfile para success/failure
            return previous.status == ProfileStatus.updatingProfile &&
                   (current.status == ProfileStatus.success || 
                    current.status == ProfileStatus.failure);
          },
          listener: (listenerContext, state) {
            // Fechar dialog quando atualização for concluída (sucesso ou erro)
            if (state.status == ProfileStatus.success || 
                state.status == ProfileStatus.failure) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (builderContext, state) {
              final isLoading = state.status == ProfileStatus.updatingProfile;
              
              return AlertDialog(
                backgroundColor: AppColors.darkGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Editar Perfil',
                  style: GoogleFonts.orbitron(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nome',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.lightGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        enabled: !isLoading,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Digite seu nome',
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bio',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.lightGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: bioController,
                        enabled: !isLoading,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Digite sua bio',
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Salvando...',
                              style: GoogleFonts.rajdhani(
                                color: AppColors.lightGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.rajdhani(
                        color: isLoading 
                            ? AppColors.mediumGrey 
                            : AppColors.lightGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final newName = nameController.text.trim();
                            final newBio = bioController.text.trim();
                            
                            builderContext.read<ProfileBloc>().add(
                                  ProfileUpdateRequested(
                                    name: newName.isNotEmpty ? newName : null,
                                    bio: newBio.isNotEmpty ? newBio : null,
                                  ),
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Salvar',
                            style: GoogleFonts.rajdhani(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Seção de Tabs (Garagem e Equipes)
class _ActiveVehicleSection extends StatefulWidget {
  const _ActiveVehicleSection();

  @override
  State<_ActiveVehicleSection> createState() => _ActiveVehicleSectionState();
}

class _ActiveVehicleSectionState extends State<_ActiveVehicleSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mediumGrey,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.lightGrey,
              labelStyle: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              unselectedLabelStyle: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              tabs: const [
                Tab(text: 'GARAGEM'),
                Tab(text: 'EQUIPES'),
                Tab(text: 'BADGES'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar View
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              controller: _tabController,
              children: const [
                _GarageTab(),
                _CrewsTab(),
                _BadgesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab de Garagem
class _GarageTab extends StatelessWidget {
  const _GarageTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final vehicles = profile?.garage ?? [];

        if (vehicles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.garage_outlined,
                  color: AppColors.lightGrey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum veículo cadastrado',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final activeVehicle = vehicles.isNotEmpty ? vehicles.first : null;
        final additionalVehiclesCount = vehicles.length - 1;
        final vehicleImageUrl = activeVehicle?.thumbnailUrl;

        if (activeVehicle == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card do veículo ativo
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do veículo
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: Container(
                        height: 220,
                        width: double.infinity,
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
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.mediumGrey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.directions_car_rounded,
                                      color: AppColors.lightGrey,
                                      size: 64,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.mediumGrey,
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car_rounded,
                                    color: AppColors.lightGrey,
                                    size: 64,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Informações do veículo
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ano
                          if (activeVehicle.year != null)
                            Text(
                              '${activeVehicle.year}',
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                color: AppColors.lightGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          if (activeVehicle.year != null) const SizedBox(height: 4),

                          // Nome completo ou nickname
                          Text(
                            activeVehicle.fullName?.toUpperCase() ??
                                activeVehicle.nickname?.toUpperCase() ??
                                'Veículo',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              letterSpacing: 1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Contador de veículos adicionais e botão Ver Garagem
                          if (additionalVehiclesCount > 0) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.mediumGrey,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.garage_rounded,
                                          color: AppColors.accent,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            '+$additionalVehiclesCount ${additionalVehiclesCount == 1 ? 'veículo' : 'veículos'} na garagem',
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 14,
                                              color: AppColors.lightGrey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    context.push(AppRouter.garageManagement);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'VER GARAGEM',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppColors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tab de Equipes
class _CrewsTab extends StatelessWidget {
  const _CrewsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final crew = profile?.crew;

        if (crew == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.group_outlined,
                  color: AppColors.lightGrey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Você ainda não está em nenhuma equipe',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Junte-se a uma equipe para começar',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (crew.insigniaUrl != null)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: crew.insigniaUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.group_rounded,
                        color: AppColors.accent,
                        size: 64,
                      ),
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.group_rounded,
                  color: AppColors.accent,
                  size: 64,
                ),
              const SizedBox(height: 16),
              Text(
                crew.name,
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '@${crew.tag}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppColors.lightGrey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (crew.isLeader) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'LÍDER',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Tab de Badges
class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final achievements = profile?.achievements ?? [];

        if (achievements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.lightGrey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum badge conquistado',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Participe de eventos oficiais para ganhar badges',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _BadgeCard(
              badge: _convertAchievementToBadge(achievement),
              onTap: () => _showBadgeDetails(context, achievement),
            );
          },
        );
      },
    );
  }

  BadgeEntity _convertAchievementToBadge(UserProfileAchievement achievement) {
    // Converter UserProfileAchievement para BadgeEntity
    return BadgeEntity(
      id: achievement.id,
      userId: '',
      eventId: '',
      eventName: achievement.name,
      eventDate: achievement.acquiredAt ?? DateTime.now(),
      badgeImageUrl: achievement.imageUrl ?? 'assets/badge_semfundo.png',
      eventDescription: null,
      eventLocation: null,
      earnedAt: achievement.acquiredAt ?? DateTime.now(),
    );
  }

  void _showBadgeDetails(
    BuildContext context,
    UserProfileAchievement achievement,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _BadgeDetailsDialog(
        badge: _convertAchievementToBadge(achievement),
      ),
    );
  }
}

/// Card de Badge com efeito 3D
class _BadgeCard extends StatefulWidget {
  const _BadgeCard({
    required this.badge,
    required this.onTap,
  });
  final BadgeEntity badge;
  final VoidCallback onTap;

  @override
  State<_BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<_BadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0;
  double _rotationY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationY += details.delta.dx * 0.01;
      _rotationX -= details.delta.dy * 0.01;
      
      // Limitar rotação
      _rotationY = _rotationY.clamp(-0.3, 0.3);
      _rotationX = _rotationX.clamp(-0.3, 0.3);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.forward().then((_) {
      _controller.reverse();
      setState(() {
        _rotationX = 0;
        _rotationY = 0;
      });
    });
  }

  Widget _buildBadgeImage() {
    // Tenta primeiro com o caminho do badge, depois com caminho hardcoded
    final imagePath = widget.badge.badgeImageUrl;
    
    try {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Erro ao carregar badge: $error');
          debugPrint('Caminho tentado: $imagePath');
          
          // Tenta com caminho alternativo
          try {
            return Image.asset(
              'assets/badge_semfundo.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error2, stackTrace2) {
                debugPrint('Erro também com caminho alternativo: $error2');
                return const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.accent,
                  size: 64,
                );
              },
            );
          } catch (e2) {
            debugPrint('Exceção com caminho alternativo: $e2');
            return const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.accent,
              size: 64,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Exceção ao carregar badge: $e');
      return const Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.accent,
        size: 64,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotationX)
          ..rotateY(_rotationY),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(_rotationY * 10, _rotationX * 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBadgeImage(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog com detalhes do Badge/Evento
class _BadgeDetailsDialog extends StatelessWidget {
  const _BadgeDetailsDialog({required this.badge});
  final BadgeEntity badge;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com imagem do badge
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.black,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        badge.badgeImageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        package: null,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Erro ao carregar badge no dialog: $error');
                          debugPrint('Stack trace: $stackTrace');
                          debugPrint('Caminho tentado: ${badge.badgeImageUrl}');
                          return const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.accent,
                            size: 80,
                          );
                        },
                      ),
                    ),
                  ),
                  // Botão fechar
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Informações do evento
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.eventName,
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (badge.eventDescription != null) ...[
                    Text(
                      badge.eventDescription!,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.lightGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(badge.eventDate),
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (badge.eventLocation != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            badge.eventLocation!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: AppColors.lightGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conquistado em ${_formatDate(badge.earnedAt)}',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
