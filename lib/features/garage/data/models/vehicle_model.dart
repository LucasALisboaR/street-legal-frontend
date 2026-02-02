import 'package:gearhead_br/features/garage/domain/entities/vehicle_entity.dart';

/// Modelo de veículo vindo da API
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
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

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['ownerId'] ?? '').toString(),
      brand: (json['brand'] ?? json['make'] ?? '').toString(),
      model: (json['model'] ?? json['carModel'] ?? '').toString(),
      year: _parseYear(json['year'] ?? json['modelYear']),
      nickname: json['nickname'] as String?,
      color: json['color'] as String?,
      licensePlate: json['licensePlate'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      specs: json['specs'] as Map<String, dynamic>?,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'year': year,
      if (nickname != null) 'nickname': nickname,
      if (color != null) 'color': color,
      if (licensePlate != null) 'licensePlate': licensePlate,
      'photoUrls': photoUrls,
      if (specs != null) 'specs': specs,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      userId: userId,
      brand: brand,
      model: model,
      year: year,
      nickname: nickname,
      color: color,
      licensePlate: licensePlate,
      photoUrls: photoUrls,
      specs: specs,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int _parseYear(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
