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

  const GarageVehicleAdded(this.vehicle);
  final VehicleEntity vehicle;

  @override
  List<Object?> get props => [vehicle];
}

/// Atualiza um veículo existente
class GarageVehicleUpdated extends GarageEvent {

  const GarageVehicleUpdated(this.vehicle);
  final VehicleEntity vehicle;

  @override
  List<Object?> get props => [vehicle];
}

/// Remove um veículo
class GarageVehicleDeleted extends GarageEvent {

  const GarageVehicleDeleted(this.vehicleId);
  final String vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}

/// Altera o veículo ativo
class GarageActiveVehicleChanged extends GarageEvent {

  const GarageActiveVehicleChanged(this.vehicleId);
  final String vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}

