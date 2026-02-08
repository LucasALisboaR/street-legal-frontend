part of 'events_bloc.dart';

enum EventsStatus { initial, loading, success, failure }

class EventsState extends Equatable {
  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const [],
    this.filter,
    this.errorMessage,
  });

  final EventsStatus status;
  final List<EventEntity> events;
  final EventType? filter;
  final String? errorMessage;

  EventsState copyWith({
    EventsStatus? status,
    List<EventEntity>? events,
    EventType? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, events, filter, errorMessage];
}
