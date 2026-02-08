part of 'crew_bloc.dart';

abstract class CrewEvent extends Equatable {
  const CrewEvent();

  @override
  List<Object?> get props => [];
}

class CrewRequested extends CrewEvent {
  const CrewRequested();
}

class CrewFilterChanged extends CrewEvent {
  const CrewFilterChanged(this.filter);

  final CrewFilter filter;

  @override
  List<Object?> get props => [filter];
}

class CrewCreated extends CrewEvent {
  const CrewCreated(this.payload);

  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [payload];
}
