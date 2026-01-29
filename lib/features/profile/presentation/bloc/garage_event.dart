part of 'garage_bloc.dart';

/// Eventos do BLoC de Garagem
abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita carregamento dos veículos
class GarageLoadRequested extends GarageEvent {
  const GarageLoadRequested();
}

/// Adiciona um novo veículo
class GarageVehicleAdded extends GarageEvent {
  final VehicleEntity vehicle;

  const GarageVehicleAdded(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Atualiza um veículo existente
class GarageVehicleUpdated extends GarageEvent {
  final VehicleEntity vehicle;

  const GarageVehicleUpdated(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Remove um veículo
class GarageVehicleDeleted extends GarageEvent {
  final String vehicleId;

  const GarageVehicleDeleted(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Altera o veículo ativo
class GarageActiveVehicleChanged extends GarageEvent {
  final String vehicleId;

  const GarageActiveVehicleChanged(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

