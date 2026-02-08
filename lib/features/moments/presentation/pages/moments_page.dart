import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/moments/domain/entities/moment_entity.dart';
import 'package:gearhead_br/features/moments/presentation/bloc/moments_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de Momentos (Feed de fotos)
class MomentsPage extends StatelessWidget {
  const MomentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MomentsBloc>()..add(const MomentsRequested()),
      child: const _MomentsView(),
    );
  }
}

class _MomentsView extends StatelessWidget {
  const _MomentsView();

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
                        'MOMENTS',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Feed da comunidade',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  _IconButton(
                    icon: Icons.add_photo_alternate_outlined,
                    onTap: () => _showCreateMomentSheet(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<MomentsBloc, MomentsState>(
                builder: (context, state) {
                  if (state.status == MomentsStatus.loading &&
                      state.moments.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }

                  if (state.status == MomentsStatus.failure) {
                    return _ErrorState(
                      message: state.errorMessage ??
                          'Não foi possível carregar moments.',
                      onRetry: () => context
                          .read<MomentsBloc>()
                          .add(const MomentsRequested()),
                    );
                  }

                  if (state.moments.isEmpty) {
                    return const _EmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async =>
                        context.read<MomentsBloc>().add(const MomentsRequested()),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.moments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final moment = state.moments[index];
                        return _MomentCard(
                          moment: moment,
                          onLikeToggle: () => context
                              .read<MomentsBloc>()
                              .add(MomentLikeToggled(moment)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const BottomNavBar(currentItem: NavItem.moments),
          ],
        ),
      ),
    );
  }

  void _showCreateMomentSheet(BuildContext context) {
    final captionController = TextEditingController();
    final locationController = TextEditingController();

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
                'Novo momento',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: captionController,
                label: 'Legenda',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: locationController,
                label: 'Local (opcional)',
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
                      if (captionController.text.isNotEmpty)
                        'caption': captionController.text,
                      if (locationController.text.isNotEmpty)
                        'locationName': locationController.text,
                      'createdAt': DateTime.now().toIso8601String(),
                    };
                    context.read<MomentsBloc>().add(MomentCreated(payload));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Publicar',
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
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({
    required this.moment,
    required this.onLikeToggle,
  });

  final MomentEntity moment;
  final VoidCallback onLikeToggle;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(moment.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initials(moment.userDisplayName ?? 'SL'),
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moment.userDisplayName ?? 'Usuário',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            size: 12,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            moment.vehicleName ?? 'Carro',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.lightGrey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $timeAgo',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.lightGrey,
                  ),
                ),
              ],
            ),
          ),

          if (moment.imageUrls.isNotEmpty)
            CachedNetworkImage(
              imageUrl: moment.imageUrls.first,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _ImagePlaceholder(),
            )
          else
            const _ImagePlaceholder(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.favorite,
                      color: AppColors.accent,
                      label: _formatCount(moment.likeCount),
                      onTap: onLikeToggle,
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      color: AppColors.white,
                      label: _formatCount(moment.commentCount),
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      color: AppColors.white,
                      label: '',
                      onTap: () {},
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.bookmark_border,
                      color: AppColors.white,
                      label: '',
                      onTap: () {},
                    ),
                  ],
                ),
                if (moment.caption != null && moment.caption!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    moment.caption!,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 8),
            Text(
              'Imagem do momento',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppColors.lightGrey,
              ),
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
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
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
        'Nenhum momento encontrado.',
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

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return count.toString();
}

String _formatTimeAgo(DateTime createdAt) {
  final diff = DateTime.now().difference(createdAt);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h';
  }
  return '${diff.inDays}d';
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
