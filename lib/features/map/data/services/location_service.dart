import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Serviço para gerenciar permissões e obter localização em tempo real
class LocationService {
  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Solicita permissão de localização
  /// Retorna true se a permissão foi concedida, false caso contrário
  Future<bool> requestLocationPermission() async {
    // Verifica se já tem permissão
    if (await hasLocationPermission()) {
      return true;
    }

    // Verifica se o serviço de localização está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Solicita permissão
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtém a localização atual do usuário
  /// Retorna null se não tiver permissão ou se o serviço estiver desabilitado
  Future<Position?> getCurrentPosition() async {
    // Verifica se tem permissão
    if (!await hasLocationPermission()) {
      final granted = await requestLocationPermission();
      if (!granted) {
        return null;
      }
    }

    // Verifica se o serviço está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    try {
      // Obtém a localização atual com alta precisão
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém atualizações de localização em tempo real
  /// Retorna um stream de posições
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // metros
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Verifica e solicita permissões necessárias
  /// Retorna true se tudo estiver ok, false caso contrário
  Future<bool> checkAndRequestPermissions() async {
    // Verifica se o serviço está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verifica e solicita permissão
    return await requestLocationPermission();
  }
}

