import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/interceptors/auth_interceptor.dart';
import 'package:gearhead_br/core/network/interceptors/error_interceptor.dart';
import 'package:gearhead_br/core/constants/mapbox_constants.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';
import 'package:gearhead_br/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/login_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/register_usecase.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/login_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/register_bloc.dart';
import 'package:gearhead_br/features/garage/data/services/garage_service.dart';
import 'package:gearhead_br/features/map/data/services/heading_service.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/data/services/mapbox_navigation_service.dart';
import 'package:gearhead_br/features/map/data/repositories/map_repository_impl.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_bloc.dart';
import 'package:gearhead_br/features/users/data/services/users_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<SessionStorage>(
    () => SessionStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      firebaseAuth: getIt<FirebaseAuth>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NETWORK
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Registrar AuthInterceptor
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      getIt<FirebaseAuth>(),
      getIt<AuthService>(),
    ),
  );

  getIt.registerLazySingleton<ErrorInterceptor>(
    () => ErrorInterceptor(getIt<AuthService>()),
  );

  // Registrar ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authInterceptor: getIt<AuthInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
      enableLogging: true, // Desabilitar em produção se necessário
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  getIt.registerLazySingleton<HeadingService>(
    () => HeadingService(),
  );

  getIt.registerLazySingleton<MapboxNavigationService>(
    () => MapboxNavigationService(
      accessToken: MapboxConstants.accessToken,
    ),
  );

  getIt.registerLazySingleton<UsersService>(
    () => UsersService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<GarageService>(
    () => GarageService(getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(getIt<LocationService>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // USE CASES
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(getIt<AuthRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BLOCS
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      loginUseCase: getIt<LoginUseCase>(),
      usersService: getIt<UsersService>(),
      sessionStorage: getIt<SessionStorage>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );

  getIt.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MAP BLOCS
  // ═══════════════════════════════════════════════════════════════════════════

  // Singleton: mantém o estado do mapa quando o usuário navega entre telas
  // Isso evita recarregar a localização toda vez que voltar para o mapa
  getIt.registerLazySingleton<MapBloc>(
    () => MapBloc(
      locationService: getIt<LocationService>(),
      headingService: getIt<HeadingService>(),
      navigationService: getIt<MapboxNavigationService>(),
      mapRepository: getIt<MapRepository>(),
    ),
  );
}
