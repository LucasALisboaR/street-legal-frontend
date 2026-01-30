import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Serviço para gerenciar permissões e obter localização em tempo real
/// 
/// OTIMIZAÇÕES IMPLEMENTADAS:
/// - LocationAccuracy.bestForNavigation para máxima precisão
/// - distanceFilter de 2 metros para atualizações frequentes mas não excessivas
/// - Intervalo explícito de 500ms no Android para evitar "lotes" de updates
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
      // Obtém a localização atual com máxima precisão para navegação
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém atualizações de localização em tempo real otimizadas para navegação
  /// 
  /// CONFIGURAÇÕES OTIMIZADAS:
  /// - accuracy: bestForNavigation - máxima precisão para uso veicular
  /// - distanceFilter: 2 metros - atualiza com frequência mas evita spam
  /// - Android: intervalo de 500ms para evitar "lotes" de atualizações
  /// - iOS: usa configurações nativas otimizadas
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
    int distanceFilter = 2, // Atualiza a cada 2 metros para movimento suave
  }) {
    // Configurações específicas por plataforma para melhor performance
    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      // Android: define intervalo explícito para evitar updates em lotes
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        // Intervalo de 500ms - bom balanço entre fluidez e performance
        intervalDuration: const Duration(milliseconds: 500),
        // Mantém GPS ativo mesmo em foreground (importante para navegação)
        forceLocationManager: false,
        // Usa Fused Location Provider para melhor precisão
        useMSLAltitude: false,
      );
    } else if (Platform.isIOS) {
      // iOS: configurações específicas para navegação
      locationSettings = AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        // Atividade de navegação - iOS otimiza para uso veicular
        activityType: ActivityType.automotiveNavigation,
        // Permite pausar atualizações automaticamente se parado
        pauseLocationUpdatesAutomatically: false,
        // Mantém atualizando em background
        showBackgroundLocationIndicator: true,
      );
    } else {
      // Fallback para outras plataformas
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
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
