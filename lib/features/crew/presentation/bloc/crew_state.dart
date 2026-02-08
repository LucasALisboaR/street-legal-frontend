part of 'crew_bloc.dart';

enum CrewStatus { initial, loading, success, failure }

enum CrewFilter { mine, discover, nearby }

class CrewState extends Equatable {
  const CrewState({
    this.status = CrewStatus.initial,
    this.crews = const [],
    this.allCrews = const [],
    this.filter = CrewFilter.mine,
    this.errorMessage,
  });

  final CrewStatus status;
  final List<CrewEntity> crews;
  final List<CrewEntity> allCrews;
  final CrewFilter filter;
  final String? errorMessage;

  CrewState copyWith({
    CrewStatus? status,
    List<CrewEntity>? crews,
    List<CrewEntity>? allCrews,
    CrewFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CrewState(
      status: status ?? this.status,
      crews: crews ?? this.crews,
      allCrews: allCrews ?? this.allCrews,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, crews, allCrews, filter, errorMessage];
}
