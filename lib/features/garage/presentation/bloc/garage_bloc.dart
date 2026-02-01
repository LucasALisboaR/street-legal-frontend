import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';

part 'garage_event.dart';
part 'garage_state.dart';

/// BLoC responsável pela gestão da Garagem
/// Gerencia veículos e seleção do veículo ativo
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  GarageBloc() : super(const GarageState()) {
    on<GarageLoadRequested>(_onLoadRequested);
    on<GarageVehicleAdded>(_onVehicleAdded);
    on<GarageVehicleUpdated>(_onVehicleUpdated);
    on<GarageVehicleDeleted>(_onVehicleDeleted);
    on<GarageActiveVehicleChanged>(_onActiveVehicleChanged);
  }

  Future<void> _onLoadRequested(
    GarageLoadRequested event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    // Mock: simula carregamento de veículos
    await Future.delayed(const Duration(seconds: 1));

    final mockVehicles = [
      VehicleEntity(
        id: '1',
        userId: 'user-1',
        brand: 'Chevrolet',
        model: 'Opala Comodoro',
        year: 1988,
        nickname: 'Opalão',
        color: 'Preto',
        licensePlate: 'ABC-1234',
        photoUrls: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      VehicleEntity(
        id: '2',
        userId: 'user-1',
        brand: 'Volkswagen',
        model: 'Fusca 1500',
        year: 1972,
        nickname: 'Fuscão',
        color: 'Azul',
        licensePlate: 'XYZ-5678',
        photoUrls: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    emit(state.copyWith(
      status: GarageStatus.loaded,
      vehicles: mockVehicles,
      activeVehicleId: mockVehicles.isNotEmpty ? mockVehicles.first.id : null,
    ),);
  }

  Future<void> _onVehicleAdded(
    GarageVehicleAdded event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    // Mock: simula adição
    await Future.delayed(const Duration(milliseconds: 500));

    final newVehicles = [...state.vehicles, event.vehicle];
    emit(state.copyWith(
      status: GarageStatus.loaded,
      vehicles: newVehicles,
      activeVehicleId:
          state.activeVehicleId ?? event.vehicle.id, // Define como ativo se for o primeiro
    ),);
  }

  Future<void> _onVehicleUpdated(
    GarageVehicleUpdated event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    await Future.delayed(const Duration(milliseconds: 500));

    final updatedVehicles = state.vehicles.map((v) {
      return v.id == event.vehicle.id ? event.vehicle : v;
    }).toList();

    emit(state.copyWith(
      status: GarageStatus.loaded,
      vehicles: updatedVehicles,
    ),);
  }

  Future<void> _onVehicleDeleted(
    GarageVehicleDeleted event,
    Emitter<GarageState> emit,
  ) async {
    emit(state.copyWith(status: GarageStatus.loading));

    await Future.delayed(const Duration(milliseconds: 500));

    final updatedVehicles =
        state.vehicles.where((v) => v.id != event.vehicleId).toList();

    // Se deletou o veículo ativo, seleciona o primeiro disponível
    String? newActiveId = state.activeVehicleId;
    if (state.activeVehicleId == event.vehicleId) {
      newActiveId = updatedVehicles.isNotEmpty ? updatedVehicles.first.id : null;
    }

    emit(state.copyWith(
      status: GarageStatus.loaded,
      vehicles: updatedVehicles,
      activeVehicleId: newActiveId,
      clearActiveVehicle: newActiveId == null,
    ),);
  }

  void _onActiveVehicleChanged(
    GarageActiveVehicleChanged event,
    Emitter<GarageState> emit,
  ) {
    emit(state.copyWith(activeVehicleId: event.vehicleId));
  }
}

