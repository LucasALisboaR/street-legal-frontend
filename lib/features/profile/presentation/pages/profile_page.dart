import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/profile/domain/entities/badge_entity.dart';

/// Página de Perfil do usuário
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GarageBloc()..add(const GarageLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
              context.go(AppRouter.login);
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

  // TODO: Obter do backend/estado do usuário
  String? get _backgroundImageUrl => null; // URL da imagem de fundo personalizada
  String? get _profilePhotoUrl => null; // URL da foto de perfil
  String get _userName => 'Alex Speed'; // TODO: Obter do UserEntity
  String get _userHandle => '@speedster99'; // TODO: Obter do UserEntity

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Imagem de fundo personalizada (atrás do card)
          if (_backgroundImageUrl != null)
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(_backgroundImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkGrey,
                    AppColors.black,
                  ],
                ),
              ),
            ),

          // Card de identidade
          Container(
            width: double.infinity,
            height: 240,
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _profilePhotoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _profilePhotoUrl!,
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
                                      _userName
                                          .split(' ')
                                          .map((n) => n[0])
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
                                    _userName
                                        .split(' ')
                                        .map((n) => n[0])
                                        .join('')
                                        .toUpperCase(),
                                    style: GoogleFonts.orbitron(
                                      fontSize: 32,
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
                        _userName,
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
                      onTap: () => _showEditNameDialog(context),
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

                const SizedBox(height: 4),

                // Handle do usuário
                Text(
                  _userHandle,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Editar Foto de Perfil',
          style: GoogleFonts.orbitron(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Funcionalidade de upload de foto será implementada em breve.',
          style: GoogleFonts.rajdhani(
            color: AppColors.lightGrey,
            fontSize: 16,
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
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: _userName);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Editar Nome',
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
              // TODO: Implementar atualização do nome via BLoC/Repository
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Nome atualizado!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
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
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        final activeVehicle = state.activeVehicle;

        if (activeVehicle == null || !state.hasVehicles) {
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

        final additionalVehiclesCount = state.vehicleCount - 1;
        final vehicleImageUrl = activeVehicle.photoUrls.isNotEmpty
            ? activeVehicle.photoUrls.first
            : null;

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
                          Text(
                            '${activeVehicle.year}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: AppColors.lightGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Marca e Modelo
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  activeVehicle.brand.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  activeVehicle.model.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
    // TODO: Integrar com BLoC de equipes quando disponível
    // Por enquanto, exibe uma lista vazia com mensagem
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
}

/// Tab de Badges
class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  // Mock data - será substituído por dados reais do BLoC
  List<BadgeEntity> get _mockBadges => [
    BadgeEntity(
      id: '1',
      userId: 'user-1',
      eventId: 'event-1',
      eventName: 'Uberlândia Drag Racing',
      eventDate: DateTime(2026, 1, 30),
      badgeImageUrl: 'assets/badge_semfundo.png',
      eventDescription: 'Evento oficial de arrancada em Uberlândia. Evolution - Gearheads Unite!',
      eventLocation: 'Uberlândia, MG',
      earnedAt: DateTime(2026, 1, 30),
    ),
    BadgeEntity(
      id: '2',
      userId: 'user-1',
      eventId: 'event-2',
      eventName: 'São Paulo Car Show',
      eventDate: DateTime(2025, 12, 15),
      badgeImageUrl: 'assets/badge_semfundo.png',
      eventDescription: 'Grande exposição de carros clássicos e modificados em São Paulo.',
      eventLocation: 'São Paulo, SP',
      earnedAt: DateTime(2025, 12, 15),
    ),
    BadgeEntity(
      id: '3',
      userId: 'user-1',
      eventId: 'event-3',
      eventName: 'Rio Cruise Night',
      eventDate: DateTime(2025, 11, 20),
      badgeImageUrl: 'assets/badge_semfundo.png',
      eventDescription: 'Cruze noturno pelas principais avenidas do Rio de Janeiro.',
      eventLocation: 'Rio de Janeiro, RJ',
      earnedAt: DateTime(2025, 11, 20),
    ),
    BadgeEntity(
      id: '4',
      userId: 'user-1',
      eventId: 'event-4',
      eventName: 'Belo Horizonte Track Day',
      eventDate: DateTime(2025, 10, 10),
      badgeImageUrl: 'assets/badge_semfundo.png',
      eventDescription: 'Dia de pista oficial em Belo Horizonte com várias categorias.',
      eventLocation: 'Belo Horizonte, MG',
      earnedAt: DateTime(2025, 10, 10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final badges = _mockBadges;

    if (badges.isEmpty) {
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
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _BadgeCard(
          badge: badge,
          onTap: () => _showBadgeDetails(context, badge),
        );
      },
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeEntity badge) {
    showDialog<void>(
      context: context,
      builder: (context) => _BadgeDetailsDialog(badge: badge),
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

