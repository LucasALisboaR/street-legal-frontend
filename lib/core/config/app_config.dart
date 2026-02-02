/// Configurações globais do app
/// 
/// Centraliza valores que podem variar por ambiente
abstract class AppConfig {
  // Base URL da API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://street-legal-backend.onrender.com',
  );
}
