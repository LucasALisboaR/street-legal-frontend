import 'dart:math';
import 'package:gearhead_br/features/map/domain/entities/navigation_entity.dart';

const double _earthRadiusMeters = 6378137.0;

double haversineDistanceMeters(MapPoint a, MapPoint b) {
  final lat1 = a.latitude * (pi / 180);
  final lat2 = b.latitude * (pi / 180);
  final deltaLat = (b.latitude - a.latitude) * (pi / 180);
  final deltaLon = (b.longitude - a.longitude) * (pi / 180);

  final haversine = sin(deltaLat / 2) * sin(deltaLat / 2) +
      cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
  final c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
  return _earthRadiusMeters * c;
}

MapPoint offsetMapPoint({
  required MapPoint origin,
  required double distanceMeters,
  required double bearingDegrees,
}) {
  final bearing = bearingDegrees * (pi / 180);
  final distanceRatio = distanceMeters / _earthRadiusMeters;
  final latRad = origin.latitude * (pi / 180);
  final lonRad = origin.longitude * (pi / 180);

  final newLat = asin(
    sin(latRad) * cos(distanceRatio) +
        cos(latRad) * sin(distanceRatio) * cos(bearing),
  );
  final newLon = lonRad +
      atan2(
        sin(bearing) * sin(distanceRatio) * cos(latRad),
        cos(distanceRatio) - sin(latRad) * sin(newLat),
      );

  return MapPoint(
    latitude: newLat * (180 / pi),
    longitude: newLon * (180 / pi),
  );
}

MapPoint randomOffsetAround({
  required MapPoint origin,
  required double minDistanceMeters,
  required double maxDistanceMeters,
  Random? random,
}) {
  final rng = random ?? Random();
  final distance = minDistanceMeters +
      rng.nextDouble() * (maxDistanceMeters - minDistanceMeters);
  final bearing = rng.nextDouble() * 360;
  return offsetMapPoint(
    origin: origin,
    distanceMeters: distance,
    bearingDegrees: bearing,
  );
}
