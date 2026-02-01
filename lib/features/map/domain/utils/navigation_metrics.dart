import 'dart:math';

class HeadingSmoother {
  HeadingSmoother({this.smoothingFactor = 0.18});

  final double smoothingFactor;
  double? _currentHeading;

  double update(double heading) {
    final normalized = normalizeHeading(heading);
    if (_currentHeading == null) {
      _currentHeading = normalized;
      return normalized;
    }

    final delta = _shortestAngleDelta(_currentHeading!, normalized);
    final next = _currentHeading! + delta * smoothingFactor;
    _currentHeading = normalizeHeading(next);
    return _currentHeading!;
  }

  double _shortestAngleDelta(double from, double to) {
    var delta = (to - from + 540) % 360 - 180;
    if (delta < -180) {
      delta += 360;
    }
    return delta;
  }
}

double normalizeHeading(double heading) {
  if (!heading.isFinite) return 0.0;
  final normalized = heading % 360;
  return normalized < 0 ? normalized + 360 : normalized;
}

double? speedToKmh(double? speedMetersPerSecond, {double minValidSpeedMps = 0.5}) {
  if (speedMetersPerSecond == null || !speedMetersPerSecond.isFinite) {
    return null;
  }
  if (speedMetersPerSecond <= minValidSpeedMps) {
    return null;
  }
  return max(0, speedMetersPerSecond) * 3.6;
}
