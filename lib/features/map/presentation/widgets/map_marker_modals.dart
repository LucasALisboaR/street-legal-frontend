import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/map/domain/entities/location_entity.dart';
import 'package:gearhead_br/features/map/domain/entities/map_user_entity.dart';

class EventDetailsSheet extends StatelessWidget {
  const EventDetailsSheet({
    super.key,
    required this.meetup,
    required this.onNavigate,
  });

  final MeetupEntity meetup;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final location = meetup.location.address?.trim();
    final organizer = meetup.organizerId.trim();
    final eventType = meetup.isPublic ? 'Público' : 'Privado';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Text(
            meetup.name.trim().isEmpty ? '—' : meetup.name,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            label: 'Tipo',
            value: eventType,
          ),
          _InfoRow(
            label: 'Local',
            value: location == null || location.isEmpty ? '—' : location,
          ),
          _InfoRow(
            label: 'Data/Hora',
            value: _formatDateTime(meetup.startTime),
          ),
          _InfoRow(
            label: 'Organizador',
            value: organizer.isEmpty ? '—' : organizer,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNavigate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ir até o evento',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailsSheet extends StatelessWidget {
  const UserDetailsSheet({
    super.key,
    required this.user,
    required this.onClose,
  });

  final MapUserEntity user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final vehicleName = user.vehicle.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Text(
            user.displayName.trim().isEmpty ? '—' : user.displayName,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Carro atual',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vehicleName.isEmpty ? '—' : vehicleName,
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          _VehicleImage(url: user.vehicleImageUrl),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.lightGrey,
              ),
              child: Text(
                'Fechar',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const _VehiclePlaceholder();
                },
                errorBuilder: (_, __, ___) => const _VehiclePlaceholder(),
              )
            : const _VehiclePlaceholder(),
      ),
    );
  }
}

class _VehiclePlaceholder extends StatelessWidget {
  const _VehiclePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black.withOpacity(0.4),
      child: const Center(
        child: Icon(
          Icons.directions_car_rounded,
          color: AppColors.lightGrey,
          size: 48,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.mediumGrey,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}
