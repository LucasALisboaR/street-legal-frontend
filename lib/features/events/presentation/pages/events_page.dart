import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/bottom_nav_bar.dart';
import 'package:gearhead_br/features/events/domain/entities/event_entity.dart';
import 'package:gearhead_br/features/events/presentation/bloc/events_bloc.dart';

/// Página de Eventos
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EventsBloc>()..add(const EventsRequested()),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatelessWidget {
  const _EventsView();

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
                        'EVENTOS',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Encontros e rolês',
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
                        icon: Icons.calendar_month_rounded,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsRequested()),
                      ),
                      const SizedBox(width: 8),
                      _IconButton(
                        icon: Icons.add_rounded,
                        isAccent: true,
                        onTap: () => _showCreateEventSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            BlocBuilder<EventsBloc, EventsState>(
              builder: (context, state) {
                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        isActive: state.filter == null,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsFilterChanged(null)),
                      ),
                      _FilterChip(
                        label: '🚗 Encontro',
                        isActive: state.filter == EventType.meetup,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsFilterChanged(EventType.meetup)),
                      ),
                      _FilterChip(
                        label: '🏆 Exposição',
                        isActive: state.filter == EventType.carshow,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsFilterChanged(EventType.carshow)),
                      ),
                      _FilterChip(
                        label: '🛣️ Rolê',
                        isActive: state.filter == EventType.cruise,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsFilterChanged(EventType.cruise)),
                      ),
                      _FilterChip(
                        label: '🏁 Track Day',
                        isActive: state.filter == EventType.race,
                        onTap: () => context
                            .read<EventsBloc>()
                            .add(const EventsFilterChanged(EventType.race)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  if (state.status == EventsStatus.loading &&
                      state.events.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }

                  if (state.status == EventsStatus.failure) {
                    return _ErrorState(
                      message: state.errorMessage ??
                          'Não foi possível carregar eventos.',
                      onRetry: () => context
                          .read<EventsBloc>()
                          .add(const EventsRequested()),
                    );
                  }

                  if (state.events.isEmpty) {
                    return const _EmptyState();
                  }

                  final grouped = _groupEvents(state.events);

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async =>
                        context.read<EventsBloc>().add(const EventsRequested()),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (grouped.today.isNotEmpty) ...[
                          const _SectionTitle(title: 'HOJE'),
                          const SizedBox(height: 12),
                          ...grouped.today.map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EventCard(event: event),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (grouped.week.isNotEmpty) ...[
                          const _SectionTitle(title: 'ESTA SEMANA'),
                          const SizedBox(height: 12),
                          ...grouped.week.map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EventCard(event: event),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),

            const BottomNavBar(currentItem: NavItem.events),
          ],
        ),
      ),
    );
  }

  void _showCreateEventSheet(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

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
                'Novo evento',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: titleController,
                label: 'Título',
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: locationController,
                label: 'Local',
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: descriptionController,
                label: 'Descrição',
                maxLines: 3,
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
                      'title': titleController.text,
                      if (locationController.text.isNotEmpty)
                        'address': locationController.text,
                      if (descriptionController.text.isNotEmpty)
                        'description': descriptionController.text,
                      'startDate': DateTime.now().add(const Duration(hours: 1))
                          .toIso8601String(),
                    };

                    context.read<EventsBloc>().add(EventCreated(payload));
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
    this.isAccent = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isAccent ? AppColors.accent : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccent ? AppColors.accent : AppColors.mediumGrey,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
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
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        letterSpacing: 2,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatEventTime(context, event);
    final location =
        event.address ?? 'Lat ${event.latitude}, Lng ${event.longitude}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: event.isOngoing
              ? AppColors.accent.withOpacity(0.5)
              : AppColors.mediumGrey,
          width: event.isOngoing ? 2 : 1,
        ),
        boxShadow: event.isOngoing
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${event.type.emoji} ${event.type.label}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (event.isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AO VIVO',
                        style: GoogleFonts.rajdhani(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.lightGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.lightGrey,
              ),
              const SizedBox(width: 4),
              Text(
                timeLabel,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: AppColors.lightGrey,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: AppColors.lightGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.participantCount}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ],
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
        'Nenhum evento encontrado.',
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

class _GroupedEvents {
  const _GroupedEvents({required this.today, required this.week});

  final List<EventEntity> today;
  final List<EventEntity> week;
}

_GroupedEvents _groupEvents(List<EventEntity> events) {
  final now = DateTime.now();
  final today = <EventEntity>[];
  final week = <EventEntity>[];

  for (final event in events) {
    if (_isSameDay(event.startDate, now)) {
      today.add(event);
    } else if (event.startDate.isBefore(now.add(const Duration(days: 7)))) {
      week.add(event);
    }
  }

  return _GroupedEvents(today: today, week: week);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatEventTime(BuildContext context, EventEntity event) {
  final time = TimeOfDay.fromDateTime(event.startDate);
  final formatted = time.format(context);
  if (event.endDate != null) {
    final end = TimeOfDay.fromDateTime(event.endDate!);
    return '$formatted - ${end.format(context)}';
  }
  return formatted;
}
