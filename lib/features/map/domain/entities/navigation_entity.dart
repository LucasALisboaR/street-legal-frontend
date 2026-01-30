import 'package:equatable/equatable.dart';

/// Representa um ponto de coordenada no mapa
class MapPoint extends Equatable {
  const MapPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory MapPoint.fromJson(Map<String, dynamic> json) => MapPoint(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
      );
}

/// Representa uma instrução de navegação (manobra)
class NavigationInstruction extends Equatable {
  const NavigationInstruction({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.maneuverType,
    this.streetName,
  });

  /// Texto da instrução (ex: "Vire à direita na Av. Paulista")
  final String instruction;

  /// Distância em metros até a próxima manobra
  final double distance;

  /// Duração estimada em segundos
  final double duration;

  /// Tipo da manobra (turn, merge, arrive, etc.)
  final String maneuverType;

  /// Nome da rua (opcional)
  final String? streetName;

  @override
  List<Object?> get props => [instruction, distance, duration, maneuverType, streetName];
}

/// Representa uma rota completa de navegação
class NavigationRoute extends Equatable {
  const NavigationRoute({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.instructions,
    this.summary,
  });

  /// Lista de coordenadas da rota (polyline decodificada)
  final List<MapPoint> coordinates;

  /// Distância total em metros
  final double distance;

  /// Duração total estimada em segundos
  final double duration;

  /// Lista de instruções de navegação
  final List<NavigationInstruction> instructions;

  /// Resumo da rota (ex: "Via BR-116")
  final String? summary;

  @override
  List<Object?> get props => [coordinates, distance, duration, instructions, summary];

  /// Distância formatada (km ou m)
  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.toInt()} m';
  }

  /// Duração formatada (h min ou min)
  String get formattedDuration {
    final minutes = (duration / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    }
    return '$minutes min';
  }
}

/// Estado da navegação ativa
class NavigationState extends Equatable {
  const NavigationState({
    required this.route,
    required this.currentPosition,
    required this.currentStepIndex,
    required this.distanceToNextStep,
    required this.isOffRoute,
  });

  /// Rota atual
  final NavigationRoute route;

  /// Posição atual do usuário
  final MapPoint currentPosition;

  /// Índice da instrução atual
  final int currentStepIndex;

  /// Distância até a próxima manobra em metros
  final double distanceToNextStep;

  /// Indica se o usuário saiu da rota
  final bool isOffRoute;

  @override
  List<Object?> get props => [
        route,
        currentPosition,
        currentStepIndex,
        distanceToNextStep,
        isOffRoute,
      ];

  /// Instrução atual
  NavigationInstruction? get currentInstruction {
    if (currentStepIndex < route.instructions.length) {
      return route.instructions[currentStepIndex];
    }
    return null;
  }

  /// Próxima instrução (se existir)
  NavigationInstruction? get nextInstruction {
    if (currentStepIndex + 1 < route.instructions.length) {
      return route.instructions[currentStepIndex + 1];
    }
    return null;
  }
}

/// Destino selecionado para navegação
class NavigationDestination extends Equatable {
  const NavigationDestination({
    required this.point,
    required this.name,
    this.address,
  });

  final MapPoint point;
  final String name;
  final String? address;

  @override
  List<Object?> get props => [point, name, address];
}

