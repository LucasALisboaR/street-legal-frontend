import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/crew/domain/entities/crew_entity.dart';
import 'package:gearhead_br/features/crew/presentation/bloc/crew_bloc.dart';

/// Página de Crews - Lista de grupos/equipes
class CrewPage extends StatelessWidget {
  const CrewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CrewBloc>()..add(const CrewRequested()),
      child: const _CrewView(),
    );
  }
}

class _CrewView extends StatelessWidget {
  const _CrewView();

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CREWS',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Encontre sua equipe',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.search_rounded,
                        onTap: () => context
                            .read<CrewBloc>()
                            .add(const CrewRequested()),
                      ),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.add_rounded,
                        onTap: () => _showCreateCrewSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            BlocBuilder<CrewBloc, CrewState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'Minhas',
                        isActive: state.filter == CrewFilter.mine,
                        onTap: () => context
                            .read<CrewBloc>()
                            .add(const CrewFilterChanged(CrewFilter.mine)),
                      ),
                      const SizedBox(width: 12),
                      _TabButton(
                        label: 'Descobrir',
                        isActive: state.filter == CrewFilter.discover,
                        onTap: () => context
                            .read<CrewBloc>()
                            .add(const CrewFilterChanged(CrewFilter.discover)),
                      ),
                      const SizedBox(width: 12),
                      _TabButton(
                        label: 'Próximas',
                        isActive: state.filter == CrewFilter.nearby,
                        onTap: () => context
                            .read<CrewBloc>()
                            .add(const CrewFilterChanged(CrewFilter.nearby)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BlocBuilder<CrewBloc, CrewState>(
                builder: (context, state) {
                  if (state.status == CrewStatus.loading &&
                      state.crews.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }

                  if (state.status == CrewStatus.failure) {
                    return _ErrorState(
                      message: state.errorMessage ??
                          'Não foi possível carregar crews.',
                      onRetry: () => context
                          .read<CrewBloc>()
                          .add(const CrewRequested()),
                    );
                  }

                  if (state.crews.isEmpty) {
                    return const _EmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async =>
                        context.read<CrewBloc>().add(const CrewRequested()),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.crews.length,
                      itemBuilder: (context, index) {
                        final crew = state.crews[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CrewCard(crew: crew),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const BottomNavBar(currentItem: NavItem.crew),
          ],
        ),
      ),
    );
  }

  void _showCreateCrewSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nova crew',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              _InputField(controller: nameController, label: 'Nome'),
              const SizedBox(height: 12),
              _InputField(
                controller: descriptionController,
                label: 'Descrição',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InputField(
                      controller: cityController,
                      label: 'Cidade',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InputField(
                      controller: stateController,
                      label: 'Estado',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final payload = {
                      'name': nameController.text,
                      if (descriptionController.text.isNotEmpty)
                        'description': descriptionController.text,
                      if (cityController.text.isNotEmpty)
                        'city': cityController.text,
                      if (stateController.text.isNotEmpty)
                        'state': stateController.text,
                    };
                    context.read<CrewBloc>().add(CrewCreated(payload));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Criar',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.mediumGrey,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.white : AppColors.lightGrey,
          ),
        ),
      ),
    );
  }
}

class _CrewCard extends StatelessWidget {
  const _CrewCard({required this.crew});

  final CrewEntity crew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGrey,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark],
              ),
            ),
            child: Center(
              child: Text(
                _initials(crew.name),
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crew.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  crew.description ?? 'Sem descrição',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.lightGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.lightGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${crew.memberCount} membros',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.lightGrey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.lightGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        crew.location.isNotEmpty ? crew.location : 'Localização',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.lightGrey,
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
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.rajdhani(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.rajdhani(color: AppColors.lightGrey),
        filled: true,
        fillColor: AppColors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhuma crew encontrada.',
        style: GoogleFonts.rajdhani(
          color: AppColors.lightGrey,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.rajdhani(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: onRetry,
              child: Text(
                'Tentar novamente',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
