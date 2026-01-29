import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';

/// Página de Momentos (Feed de fotos)
class MomentsPage extends StatelessWidget {
  const MomentsPage({super.key});

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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Postar momento em desenvolvimento'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Feed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _MomentCard(
                    username: 'Carlos_Turbo',
                    vehicleName: 'Civic Si 2008',
                    timeAgo: '2h',
                    caption: 'Depois de muito trabalho, finalmente terminei o setup do turbo. 450cv no dyno! 🔥',
                    likeCount: 234,
                    commentCount: 45,
                    isLiked: true,
                  ),
                  SizedBox(height: 16),
                  _MomentCard(
                    username: 'Opala_do_Zé',
                    vehicleName: 'Opala Comodoro 1988',
                    timeAgo: '5h',
                    caption: 'Rolê de domingo com a família. Nada como o ronco de um 6 cilindros.',
                    likeCount: 567,
                    commentCount: 89,
                    isLiked: false,
                  ),
                  SizedBox(height: 16),
                  _MomentCard(
                    username: 'Fusca_Preto',
                    vehicleName: 'Fusca 1972',
                    timeAgo: '8h',
                    caption: 'Encontro VW Ar no Ibirapuera foi sensacional! Mais de 200 carros.',
                    likeCount: 892,
                    commentCount: 156,
                    isLiked: true,
                  ),
                  SizedBox(height: 16),
                  _MomentCard(
                    username: 'V8_Maniaco',
                    vehicleName: 'Mustang GT 2019',
                    timeAgo: '1d',
                    caption: 'Track day em Interlagos. Melhor tempo: 2:15.3 🏁',
                    likeCount: 1205,
                    commentCount: 234,
                    isLiked: false,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Navigation
            const BottomNavBar(currentItem: NavItem.moments),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

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
  final String username;
  final String vehicleName;
  final String timeAgo;
  final String caption;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const _MomentCard({
    required this.username,
    required this.vehicleName,
    required this.timeAgo,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mediumGrey,
          width: 1,
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
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      username[0].toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
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
                        username,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 12,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicleName,
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

          // Image placeholder
          Container(
            height: 250,
            width: double.infinity,
            color: AppColors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
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
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppColors.accent : AppColors.white,
                      label: _formatCount(likeCount),
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      color: AppColors.white,
                      label: _formatCount(commentCount),
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
                const SizedBox(height: 12),
                Text(
                  caption,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

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

