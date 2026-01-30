# Integração com Backend

Esta pasta contém toda a configuração necessária para integração com o backend da aplicação.

## Estrutura

```
lib/core/network/
├── api_client.dart              # Cliente HTTP principal (Dio)
├── api_endpoints.dart            # Centralização de todos os endpoints
├── data_sources/
│   ├── base_data_source.dart    # Classe base para data sources
│   └── example_data_source.dart  # Exemplo de uso
├── interceptors/
│   ├── auth_interceptor.dart     # Adiciona token de autenticação
│   ├── error_interceptor.dart    # Tratamento centralizado de erros
│   └── logging_interceptor.dart  # Logs formatados das requisições
└── models/
    ├── api_error.dart            # Modelo de erro da API
    └── api_response.dart         # Modelo genérico de resposta
```

## Configuração

### 1. Configurar URL Base

Edite `lib/core/constants/app_constants.dart` e configure a URL base do backend:

```dart
static const String apiBaseUrl = 'https://api.seu-backend.com/api';
```

Ou use variáveis de ambiente:

```bash
flutter run --dart-define=API_BASE_URL=https://api.seu-backend.com/api
```

### 2. Criar um Data Source

Crie um data source que herda de `BaseDataSource`:

```dart
import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';

class MyDataSource extends BaseDataSource {
  MyDataSource(super.apiClient);

  Future<Either<ApiError, MyModel>> getData() {
    return executeRequest<MyModel>(
      request: () => apiClient.get(ApiEndpoints.myEndpoint),
      fromJson: (json) => MyModel.fromJson(json),
    );
  }
}
```

### 3. Registrar no GetIt

Adicione o data source no `lib/core/di/injection.dart`:

```dart
getIt.registerLazySingleton<MyDataSource>(
  () => MyDataSource(getIt<ApiClient>()),
);
```

### 4. Usar no Repositório

Use o data source no repositório:

```dart
class MyRepositoryImpl implements MyRepository {
  MyRepositoryImpl(this._dataSource);
  
  final MyDataSource _dataSource;

  @override
  Future<Either<Failure, MyModel>> getData() async {
    final result = await _dataSource.getData();
    return result.fold(
      (error) => Left(MyFailure(error.message)),
      (data) => Right(data),
    );
  }
}
```

## Funcionalidades

### Autenticação Automática

O `AuthInterceptor` adiciona automaticamente o token do Firebase Auth em todas as requisições:

```dart
Authorization: Bearer <token>
```

### Tratamento de Erros

O `BaseDataSource` trata automaticamente os seguintes erros:

- **Timeout**: Erros de conexão/timeout
- **401**: Não autorizado
- **404**: Não encontrado
- **500+**: Erros do servidor
- **Conexão**: Erros de rede

### Logging

Em modo debug, todas as requisições são logadas de forma formatada usando `pretty_dio_logger`.

## Endpoints

Todos os endpoints estão centralizados em `api_endpoints.dart`. Adicione novos endpoints lá:

```dart
static const String myEndpoint = '/my-endpoint';
static String myEndpointWithId(String id) => '/my-endpoint/$id';
```

## Exemplo Completo

Veja `example_data_source.dart` para um exemplo completo de como criar e usar um data source.

