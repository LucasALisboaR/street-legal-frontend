import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';

/// Exemplo de data source
/// 
/// Este arquivo demonstra como criar um data source que herda de BaseDataSource
/// Você pode usar este como referência para criar seus próprios data sources
class ExampleDataSource extends BaseDataSource {
  ExampleDataSource(super.apiClient);

  /// Exemplo de GET request
  Future<Either<ApiError, Map<String, dynamic>>> getExample() {
    return executeRequest<Map<String, dynamic>>(
      request: () => apiClient.get(ApiEndpoints.profile),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Exemplo de POST request
  Future<Either<ApiError, Map<String, dynamic>>> postExample(
    Map<String, dynamic> data,
  ) {
    return executeRequest<Map<String, dynamic>>(
      request: () => apiClient.post(
        ApiEndpoints.profile,
        data: data,
      ),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Exemplo de GET request que retorna uma lista
  Future<Either<ApiError, List<Map<String, dynamic>>>> getListExample() {
    return executeListRequest<Map<String, dynamic>>(
      request: () => apiClient.get(ApiEndpoints.vehicles),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Exemplo de requisição com tratamento manual de erro
  Future<Either<ApiError, String>> getExampleWithManualErrorHandling() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/example');
      return Right(response.data?['message'] as String? ?? '');
    } catch (e) {
      return handleError<String>(e);
    }
  }
}

