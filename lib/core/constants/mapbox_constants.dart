/// Constantes do Mapbox
/// 
/// ⚠️ IMPORTANTE: Substitua o token abaixo pelo seu token de acesso do Mapbox
/// Obtenha seu token em: https://account.mapbox.com/
/// 
/// Para produção, considere usar variáveis de ambiente ou um sistema
/// seguro de gerenciamento de secrets.
abstract class MapboxConstants {
  /// Token de acesso do Mapbox
  /// 
  /// Substitua 'YOUR_MAPBOX_ACCESS_TOKEN_HERE' pelo seu token real
  static const String accessToken = 'pk.eyJ1IjoibHVjYXNsaXNib2EiLCJhIjoiY2xraDFmdWJ4MDF1cDNlbnk5Z25oN3FjNyJ9.XfaFVX1TIK2FVEZu26Urmw';
  
  /// URL base da API Mapbox Directions
  static const String directionsApiUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  
  /// URL base da API Mapbox Geocoding
  static const String geocodingApiUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  
  /// Estilos de mapa disponíveis
  static const String styleStreets = 'mapbox://styles/mapbox/streets-v12';
  static const String styleDark = 'mapbox://styles/mapbox/dark-v11';
  static const String styleLight = 'mapbox://styles/mapbox/light-v11';
  static const String styleOutdoors = 'mapbox://styles/mapbox/outdoors-v12';
  static const String styleSatellite = 'mapbox://styles/mapbox/satellite-v9';
  static const String styleNavDay = 'mapbox://styles/mapbox/navigation-day-v1';
  static const String styleNavNight = 'mapbox://styles/mapbox/navigation-night-v1';
}

