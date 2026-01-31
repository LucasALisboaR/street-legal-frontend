import 'package:flutter_compass/flutter_compass.dart';
import 'package:gearhead_br/features/map/domain/utils/navigation_metrics.dart';

class HeadingService {
  Stream<double> getHeadingStream() {
    final stream = FlutterCompass.events;
    if (stream == null) {
      return const Stream.empty();
    }

    return stream
        .where((event) => event.heading != null)
        .map((event) => normalizeHeading(event.heading!));
  }
}
