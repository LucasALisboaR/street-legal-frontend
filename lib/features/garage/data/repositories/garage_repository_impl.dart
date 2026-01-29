import 'package:dartz/dartz.dart';
import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';
import 'package:gearhead_br/features/garage/domain/repositories/garage_repository.dart';

/// Implementação mock do repositório da garagem
/// TODO: Substituir por implementação real
class GarageRepositoryImpl implements GarageRepository {
  // Mock de veículos
  final List<VehicleEntity> _mockVehicles = [
    VehicleEntity(
      id: '1',
      userId: 'mock-user-id',
      brand: 'Chevrolet',
      model: 'Opala',
      year: 1978,
      nickname: 'Opalão',
      color: 'Preto',
      licensePlate: 'ABC-1234',
      photoUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    VehicleEntity(
      id: '2',
      userId: 'mock-user-id',
      brand: 'Volkswagen',
      model: 'Gol GTI',
      year: 1994,
      nickname: 'Bolinha',
      color: 'Vermelho',
      licensePlate: 'XYZ-5678',
      photoUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<Either<GarageFailure, List<VehicleEntity>>> getVehicles() async {
    await Future.delayed(const Duration(seconds: 1));
    return Right(_mockVehicles);
  }

  @override
  Future<Either<GarageFailure, VehicleEntity>> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final vehicle = _mockVehicles.firstWhere((v) => v.id == id);
      return Right(vehicle);
    } catch (_) {
      return const Left(VehicleNotFoundFailure());
    }
  }

  @override
  Future<Either<GarageFailure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockVehicles.add(vehicle);
    return Right(vehicle);
  }

  @override
  Future<Either<GarageFailure, VehicleEntity>> updateVehicle(VehicleEntity vehicle) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _mockVehicles.indexWhere((v) => v.id == vehicle.id);
    if (index == -1) {
      return const Left(VehicleNotFoundFailure());
    }
    
    _mockVehicles[index] = vehicle;
    return Right(vehicle);
  }

  @override
  Future<Either<GarageFailure, void>> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockVehicles.removeWhere((v) => v.id == id);
    return const Right(null);
  }
}

