import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';

/// Falhas relacionadas à garagem
abstract class GarageFailure {
  const GarageFailure(this.message);
  final String message;
}

class VehicleNotFoundFailure extends GarageFailure {
  const VehicleNotFoundFailure() : super('Veículo não encontrado');
}

class GarageNetworkFailure extends GarageFailure {
  const GarageNetworkFailure() : super('Erro de conexão');
}

/// Interface do repositório da garagem
abstract class GarageRepository {
  /// Busca todos os veículos do usuário
  Future<Either<GarageFailure, List<VehicleEntity>>> getVehicles();

  /// Busca um veículo específico
  Future<Either<GarageFailure, VehicleEntity>> getVehicleById(String id);

  /// Adiciona um novo veículo
  Future<Either<GarageFailure, VehicleEntity>> addVehicle(VehicleEntity vehicle);

  /// Atualiza um veículo
  Future<Either<GarageFailure, VehicleEntity>> updateVehicle(VehicleEntity vehicle);

  /// Remove um veículo
  Future<Either<GarageFailure, void>> deleteVehicle(String id);
}

