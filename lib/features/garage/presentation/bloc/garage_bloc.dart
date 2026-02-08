import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/garage/data/services/garage_service.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';

part 'garage_event.dart';
part 'garage_state.dart';

/// BLoC responsável pela gestão da Garagem
/// Gerencia veículos e seleção do veículo ativo
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  GarageBloc({
    required GarageService garageService,
    required SessionStorage sessionStorage,
  })  : _garageService = garageService,
        _sessionStorage = sessionStorage,
        super(const GarageState()) {
    on<GarageLoadRequested>(_onLoadRequested);
    on<GarageVehicleAdded>(_onVehicleAdded);
    on<GarageVehicleUpdated>(_onVehicleUpdated);
    on<GarageVehicleDeleted>(_onVehicleDeleted);
    on<GarageActiveVehicleChanged>(_onActiveVehicleChanged);
  }

  final GarageService _garageService;
  final SessionStorage _sessionStorage;

  Future<void> _onLoadRequested(
    GarageLoadRequested event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: 'Usuário não autenticado.',
      ));
      return;
    }

    final result = await _garageService.getGarage(userId);
    result.fold(
      (error) => emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: error.message,
      )),
      (vehicles) => emit(state.copyWith(
        status: GarageStatus.loaded,
        vehicles: vehicles,
        activeVehicleId: vehicles.isNotEmpty ? vehicles.first.id : null,
      )),
    );
  }

  Future<void> _onVehicleAdded(
    GarageVehicleAdded event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: 'Usuário não autenticado.',
      ));
      return;
    }

    final result = await _garageService.addVehicle(
      userId,
      _vehiclePayload(event.vehicle),
    );
    result.fold(
      (error) => emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: error.message,
      )),
      (vehicle) => emit(state.copyWith(
        status: GarageStatus.loaded,
        vehicles: [...state.vehicles, vehicle],
        activeVehicleId: state.activeVehicleId ?? vehicle.id,
      )),
    );
  }

  Future<void> _onVehicleUpdated(
    GarageVehicleUpdated event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: 'Usuário não autenticado.',
      ));
      return;
    }

    final result = await _garageService.updateVehicle(
      userId,
      event.vehicle.id,
      _vehiclePayload(event.vehicle),
    );
    result.fold(
      (error) => emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: error.message,
      )),
      (vehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == vehicle.id ? vehicle : v;
        }).toList();

        emit(state.copyWith(
          status: GarageStatus.loaded,
          vehicles: updatedVehicles,
        ));
      },
    );
  }

  Future<void> _onVehicleDeleted(
    GarageVehicleDeleted event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: 'Usuário não autenticado.',
      ));
      return;
    }

    final result = await _garageService.deleteVehicle(userId, event.vehicleId);
    result.fold(
      (error) => emit(state.copyWith(
        status: GarageStatus.error,
        errorMessage: error.message,
      )),
      (_) {
        final updatedVehicles =
            state.vehicles.where((v) => v.id != event.vehicleId).toList();

        String? newActiveId = state.activeVehicleId;
        if (state.activeVehicleId == event.vehicleId) {
          newActiveId = updatedVehicles.isNotEmpty ? updatedVehicles.first.id : null;
        }

        emit(state.copyWith(
          status: GarageStatus.loaded,
          vehicles: updatedVehicles,
          activeVehicleId: newActiveId,
          clearActiveVehicle: newActiveId == null,
        ));
      },
    );
  }

  void _onActiveVehicleChanged(
    GarageActiveVehicleChanged event,
    Emitter<GarageState> emit,
  ) {
    emit(state.copyWith(activeVehicleId: event.vehicleId));
  }

  Map<String, dynamic> _vehiclePayload(VehicleEntity vehicle) {
    return {
      'brand': vehicle.brand,
      'model': vehicle.model,
      'year': vehicle.year,
      if (vehicle.nickname != null) 'nickname': vehicle.nickname,
      if (vehicle.color != null) 'color': vehicle.color,
      if (vehicle.licensePlate != null) 'licensePlate': vehicle.licensePlate,
      if (vehicle.photoUrls.isNotEmpty) 'photoUrls': vehicle.photoUrls,
      if (vehicle.specs != null) 'specs': vehicle.specs,
    };
  }
}
