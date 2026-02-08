import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/crew/data/services/crew_service.dart';
import 'package:gearhead_br/features/crew/domain/entities/crew_entity.dart';

part 'crew_event.dart';
part 'crew_state.dart';

class CrewBloc extends Bloc<CrewEvent, CrewState> {
  CrewBloc({
    required CrewService crewService,
    required SessionStorage sessionStorage,
  })  : _crewService = crewService,
        _sessionStorage = sessionStorage,
        super(const CrewState()) {
    on<CrewRequested>(_onCrewRequested);
    on<CrewFilterChanged>(_onCrewFilterChanged);
    on<CrewCreated>(_onCrewCreated);
  }

  final CrewService _crewService;
  final SessionStorage _sessionStorage;

  Future<void> _onCrewRequested(
    CrewRequested event,
    Emitter<CrewState> emit,
  ) async {
    emit(state.copyWith(status: CrewStatus.loading, clearError: true));
    final result = await _crewService.getCrews();

    await result.fold(
      (error) async => emit(state.copyWith(
        status: CrewStatus.failure,
        errorMessage: error.message,
      )),
      (crews) async {
        final filtered = await _applyFilter(crews, state.filter);
        emit(state.copyWith(
          status: CrewStatus.success,
          crews: filtered,
          allCrews: crews,
        ));
      },
    );
  }

  Future<void> _onCrewFilterChanged(
    CrewFilterChanged event,
    Emitter<CrewState> emit,
  ) async {
    final filtered = await _applyFilter(state.allCrews, event.filter);
    emit(state.copyWith(filter: event.filter, crews: filtered));
  }

  Future<void> _onCrewCreated(
    CrewCreated event,
    Emitter<CrewState> emit,
  ) async {
    emit(state.copyWith(status: CrewStatus.loading, clearError: true));
    final result = await _crewService.createCrew(event.payload);
    await result.fold(
      (error) async => emit(state.copyWith(
        status: CrewStatus.failure,
        errorMessage: error.message,
      )),
      (_) async => add(const CrewRequested()),
    );
  }

  Future<List<CrewEntity>> _applyFilter(
    List<CrewEntity> crews,
    CrewFilter filter,
  ) async {
    if (filter == CrewFilter.nearby) {
      return crews.where((crew) => crew.city != null).toList();
    }

    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return filter == CrewFilter.mine ? [] : crews;
    }

    if (filter == CrewFilter.mine) {
      return crews
          .where(
            (crew) =>
                crew.ownerId == userId || crew.memberIds.contains(userId),
          )
          .toList();
    }

    return crews
        .where(
          (crew) =>
              crew.isPublic &&
              crew.ownerId != userId &&
              !crew.memberIds.contains(userId),
        )
        .toList();
  }
}
