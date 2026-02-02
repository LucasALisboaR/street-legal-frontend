import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Interceptor para logging de requisições HTTP
/// 
/// Usa pretty_dio_logger para logs formatados e legíveis
/// Apenas ativo em modo debug
class LoggingInterceptor extends PrettyDioLogger {
  LoggingInterceptor()
      : super(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        );
}
