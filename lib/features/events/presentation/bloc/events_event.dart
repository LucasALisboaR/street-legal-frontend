part of 'events_bloc.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class EventsRequested extends EventsEvent {
  const EventsRequested();
}

class EventsFilterChanged extends EventsEvent {
  const EventsFilterChanged(this.filter);

  final EventType? filter;

  @override
  List<Object?> get props => [filter];
}

class EventCreated extends EventsEvent {
  const EventCreated(this.payload);

  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [payload];
}
