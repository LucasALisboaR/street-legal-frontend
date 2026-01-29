part of 'garage_bloc.dart';

/// Status da garagem
enum GarageStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado do BLoC de Garagem
class GarageState extends Equatable {

  const GarageState({
    this.status = GarageStatus.initial,
    this.vehicles = const [],
    this.activeVehicleId,
    this.errorMessage,
  });
  final GarageStatus status;
  final List<VehicleEntity> vehicles;
  final String? activeVehicleId;
  final String? errorMessage;

  /// Retorna o veículo ativo
  VehicleEntity? get activeVehicle {
    if (activeVehicleId == null) return null;
    try {
      return vehicles.firstWhere((v) => v.id == activeVehicleId);
    } catch (_) {
      return null;
    }
  }

  /// Verifica se há veículos
  bool get hasVehicles => vehicles.isNotEmpty;

  /// Total de veículos
  int get vehicleCount => vehicles.length;

  GarageState copyWith({
    GarageStatus? status,
    List<VehicleEntity>? vehicles,
    String? activeVehicleId,
    String? errorMessage,
    bool clearActiveVehicle = false,
  }) {
    return GarageState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      activeVehicleId:
          clearActiveVehicle ? null : (activeVehicleId ?? this.activeVehicleId),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, activeVehicleId, errorMessage];
}

