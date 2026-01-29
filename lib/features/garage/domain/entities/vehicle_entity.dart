import 'package:equatable/equatable.dart';

/// Entidade de veículo
/// Representa um carro na garagem digital do usuário
class VehicleEntity extends Equatable {

  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.createdAt, required this.updatedAt, this.nickname,
    this.color,
    this.licensePlate,
    this.photoUrls = const [],
    this.specs,
  });
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? nickname;
  final String? color;
  final String? licensePlate;
  final List<String> photoUrls;
  final Map<String, dynamic>? specs;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nome de exibição do veículo
  String get displayName => nickname ?? '$brand $model';

  /// Descrição completa
  String get fullDescription => '$brand $model $year';

  @override
  List<Object?> get props => [
        id,
        userId,
        brand,
        model,
        year,
        nickname,
        color,
        licensePlate,
        photoUrls,
        specs,
        createdAt,
        updatedAt,
      ];

  VehicleEntity copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    int? year,
    String? nickname,
    String? color,
    String? licensePlate,
    List<String>? photoUrls,
    Map<String, dynamic>? specs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrls: photoUrls ?? this.photoUrls,
      specs: specs ?? this.specs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

