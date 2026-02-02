/// Configurações globais do app
/// 
/// Centraliza valores que podem variar por ambiente
abstract class AppConfig {
  // Base URL da API
  static const String localUrl = 'http://192.168.13.29:3000';
  static const String devUrl = 'https://street-legal-backend.onrender.com';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: localUrl,
  );
}
