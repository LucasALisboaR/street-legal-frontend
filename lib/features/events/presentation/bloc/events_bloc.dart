import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/events/data/services/events_service.dart';
import 'package:gearhead_br/features/events/domain/entities/event_entity.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc({required EventsService eventsService})
      : _eventsService = eventsService,
        super(const EventsState()) {
    on<EventsRequested>(_onEventsRequested);
    on<EventsFilterChanged>(_onEventsFilterChanged);
    on<EventCreated>(_onEventCreated);
  }

  final EventsService _eventsService;

  Future<void> _onEventsRequested(
    EventsRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(state.copyWith(status: EventsStatus.loading, clearError: true));
    final result = await _eventsService.getEvents(
      type: _mapTypeToQuery(state.filter),
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: EventsStatus.failure,
        errorMessage: error.message,
      )),
      (events) => emit(state.copyWith(
        status: EventsStatus.success,
        events: events,
      )),
    );
  }

  Future<void> _onEventsFilterChanged(
    EventsFilterChanged event,
    Emitter<EventsState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    add(const EventsRequested());
  }

  Future<void> _onEventCreated(
    EventCreated event,
    Emitter<EventsState> emit,
  ) async {
    emit(state.copyWith(status: EventsStatus.loading, clearError: true));
    final result = await _eventsService.createEvent(event.payload);
    await result.fold(
      (error) async => emit(state.copyWith(
        status: EventsStatus.failure,
        errorMessage: error.message,
      )),
      (_) async => add(const EventsRequested()),
    );
  }

  String? _mapTypeToQuery(EventType? type) {
    switch (type) {
      case EventType.meetup:
        return 'meetup';
      case EventType.carshow:
        return 'carshow';
      case EventType.cruise:
        return 'cruise';
      case EventType.race:
        return 'race';
      case EventType.workshop:
        return 'workshop';
      case null:
        return null;
    }
  }
}
