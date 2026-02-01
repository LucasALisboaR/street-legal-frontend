import 'package:dio/dio.dart';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';

/// Serviço para comunicação com a API Mapbox Directions
/// Responsável por calcular rotas e fornecer instruções de navegação
class MapboxNavigationService {
  MapboxNavigationService({
    required this.accessToken,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String accessToken;
  final Dio _dio;

  static const String _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  /// Calcula uma rota entre dois pontos
  /// [origin] - Ponto de origem
  /// [destination] - Ponto de destino
  /// [profile] - Perfil de roteamento: 'driving', 'driving-traffic', 'walking', 'cycling'
  Future<NavigationRoute?> getRoute({
    required MapPoint origin,
    required MapPoint destination,
    String profile = 'driving-traffic',
  }) async {
    try {
      final coordinates = '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
      
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$profile/$coordinates',
        queryParameters: {
          'access_token': accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': 'true',
          'language': 'pt-BR',
          'voice_instructions': 'true',
          'banner_instructions': 'true',
          // Traz anotação de velocidade máxima para o badge de limite.
          'annotations': 'maxspeed',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          return _parseRoute(routes.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      // Log do erro em ambiente de desenvolvimento
      print('Erro ao obter rota: $e');
      return null;
    }
  }

  /// Recalcula a rota quando o usuário sai do caminho
  Future<NavigationRoute?> recalculateRoute({
    required MapPoint currentPosition,
    required MapPoint destination,
    String profile = 'driving-traffic',
  }) async {
    return getRoute(
      origin: currentPosition,
      destination: destination,
      profile: profile,
    );
  }

  /// Verifica se o usuário está fora da rota
  /// [currentPosition] - Posição atual do usuário
  /// [routeCoordinates] - Coordenadas da rota
  /// [tolerance] - Tolerância em metros (padrão: 50m)
  bool isOffRoute({
    required MapPoint currentPosition,
    required List<MapPoint> routeCoordinates,
    double tolerance = 50.0,
  }) {
    if (routeCoordinates.isEmpty) return true;

    // Encontra a menor distância do ponto atual para qualquer segmento da rota
    double minDistance = double.infinity;

    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      final distance = _distanceToSegment(
        currentPosition,
        routeCoordinates[i],
        routeCoordinates[i + 1],
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance > tolerance;
  }

  /// Calcula a distância de um ponto a um segmento de reta
  double _distanceToSegment(MapPoint point, MapPoint segmentStart, MapPoint segmentEnd) {
    final dx = segmentEnd.longitude - segmentStart.longitude;
    final dy = segmentEnd.latitude - segmentStart.latitude;

    if (dx == 0 && dy == 0) {
      return _haversineDistance(point, segmentStart);
    }

    final t = ((point.longitude - segmentStart.longitude) * dx +
            (point.latitude - segmentStart.latitude) * dy) /
        (dx * dx + dy * dy);

    final tClamped = t.clamp(0.0, 1.0);

    final nearestPoint = MapPoint(
      latitude: segmentStart.latitude + tClamped * dy,
      longitude: segmentStart.longitude + tClamped * dx,
    );

    return _haversineDistance(point, nearestPoint);
  }

  /// Calcula a distância entre dois pontos usando a fórmula de Haversine
  double _haversineDistance(MapPoint p1, MapPoint p2) {
    const earthRadius = 6371000.0; // metros

    final lat1 = p1.latitude * 3.141592653589793 / 180;
    final lat2 = p2.latitude * 3.141592653589793 / 180;
    final dLat = (p2.latitude - p1.latitude) * 3.141592653589793 / 180;
    final dLon = (p2.longitude - p1.longitude) * 3.141592653589793 / 180;

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(lat1) * _cos(lat2) * _sin(dLon / 2) * _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  // Funções matemáticas auxiliares
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorSin(x + 1.5707963267948966);
  double _sqrt(double x) => x > 0 ? _newtonSqrt(x) : 0;
  
  double _taylorSin(double x) {
    // Normaliza x para [-π, π]
    while (x > 3.141592653589793) x -= 6.283185307179586;
    while (x < -3.141592653589793) x += 6.283185307179586;
    
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _newtonSqrt(double x) {
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 1.5707963267948966;
    if (x == 0 && y < 0) return -1.5707963267948966;
    return 0;
  }

  double _atan(double x) {
    if (x > 1) return 1.5707963267948966 - _atan(1 / x);
    if (x < -1) return -1.5707963267948966 - _atan(1 / x);
    double result = x;
    double term = x;
    for (int i = 1; i <= 15; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  /// Parseia a resposta da API em uma NavigationRoute
  NavigationRoute _parseRoute(Map<String, dynamic> routeData) {
    final geometry = routeData['geometry'] as Map<String, dynamic>;
    final coordinates = (geometry['coordinates'] as List)
        .map((coord) => MapPoint(
              latitude: (coord as List)[1] as double,
              longitude: coord[0] as double,
            ))
        .toList();

    final legs = routeData['legs'] as List;
    final instructions = <NavigationInstruction>[];
    final speedLimits = <double?>[];

    for (final leg in legs) {
      final legData = leg as Map<String, dynamic>;
      final steps = legData['steps'] as List;
      for (final step in steps) {
        final stepData = step as Map<String, dynamic>;
        final maneuver = stepData['maneuver'] as Map<String, dynamic>;

        instructions.add(NavigationInstruction(
          instruction: maneuver['instruction'] as String? ?? '',
          distance: (stepData['distance'] as num).toDouble(),
          duration: (stepData['duration'] as num).toDouble(),
          maneuverType: maneuver['type'] as String? ?? 'unknown',
          streetName: stepData['name'] as String?,
        ));
      }

      // Extrai anotação de velocidade máxima (se disponível).
      final annotation = legData['annotation'] as Map<String, dynamic>?;
      final maxspeed = annotation?['maxspeed'] as List?;
      if (maxspeed != null) {
        for (final entry in maxspeed) {
          speedLimits.add(_parseSpeedLimitToKmh(entry));
        }
      }
    }

    return NavigationRoute(
      coordinates: coordinates,
      distance: (routeData['distance'] as num).toDouble(),
      duration: (routeData['duration'] as num).toDouble(),
      instructions: instructions,
      speedLimitsKmh: speedLimits,
      summary: routeData['weight_name'] as String?,
    );
  }

  /// Converte o valor de velocidade máxima retornado pela API para km/h.
  double? _parseSpeedLimitToKmh(dynamic entry) {
    if (entry == null) return null;
    if (entry is num) {
      return entry.toDouble();
    }
    if (entry is Map<String, dynamic>) {
      final speed = entry['speed'] as num?;
      final unit = entry['unit'] as String?;
      if (speed == null) return null;
      if (unit == null || unit.toLowerCase().contains('km')) {
        return speed.toDouble();
      }
      if (unit.toLowerCase().contains('mph')) {
        return speed.toDouble() * 1.60934;
      }
      return speed.toDouble();
    }
    return null;
  }

  /// Encontra o índice do segmento mais próximo na rota
  int findNearestSegmentIndex({
    required MapPoint currentPosition,
    required List<MapPoint> routeCoordinates,
  }) {
    if (routeCoordinates.isEmpty) return 0;

    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      final distance = _distanceToSegment(
        currentPosition,
        routeCoordinates[i],
        routeCoordinates[i + 1],
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  /// Calcula a distância até o próximo passo da navegação
  double calculateDistanceToNextStep({
    required MapPoint currentPosition,
    required MapPoint nextStepPosition,
  }) {
    return _haversineDistance(currentPosition, nextStepPosition);
  }
}
