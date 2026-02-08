import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gearhead_br/core/auth/auth_service.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/interceptors/auth_interceptor.dart';
import 'package:gearhead_br/core/network/interceptors/error_interceptor.dart';
import 'package:gearhead_br/core/constants/mapbox_constants.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/auth/data/services/auth_api_service.dart';
import 'package:gearhead_br/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';
import 'package:gearhead_br/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/login_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/register_usecase.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/login_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/register_bloc.dart';
import 'package:gearhead_br/features/crew/data/services/crew_service.dart';
import 'package:gearhead_br/features/crew/presentation/bloc/crew_bloc.dart';
import 'package:gearhead_br/features/events/data/services/events_service.dart';
import 'package:gearhead_br/features/events/presentation/bloc/events_bloc.dart';
import 'package:gearhead_br/features/garage/data/services/garage_service.dart';
import 'package:gearhead_br/features/garage/presentation/bloc/garage_bloc.dart';
import 'package:gearhead_br/features/map/data/services/heading_service.dart';
import 'package:gearhead_br/features/map/data/services/location_service.dart';
import 'package:gearhead_br/features/map/data/services/map_service.dart';
import 'package:gearhead_br/features/map/data/services/mapbox_navigation_service.dart';
import 'package:gearhead_br/features/map/data/repositories/map_repository_impl.dart';
import 'package:gearhead_br/features/map/domain/repositories/map_repository.dart';
import 'package:gearhead_br/features/map/presentation/bloc/map_bloc.dart';
import 'package:gearhead_br/features/moments/data/services/moments_service.dart';
import 'package:gearhead_br/features/moments/presentation/bloc/moments_bloc.dart';
import 'package:gearhead_br/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gearhead_br/features/users/data/services/users_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Reset GetIt se já estiver configurado (útil para hot reload)
  // Isso garante que todas as dependências sejam registradas novamente
  if (getIt.isRegistered<UsersService>() || getIt.isRegistered<ApiClient>()) {
    getIt.reset();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STORAGE
  // ═══════════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<SessionStorage>(
    () => SessionStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NETWORK
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Registrar AuthInterceptor
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      getIt<SessionStorage>(),
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

  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<GarageService>(
    () => GarageService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<EventsService>(
    () => EventsService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CrewService>(
    () => CrewService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<MomentsService>(
    () => MomentsService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<MapService>(
    () => MapService(getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApiService: getIt<AuthApiService>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(
      locationService: getIt<LocationService>(),
      mapService: getIt<MapService>(),
    ),
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
      usersService: getIt<UsersService>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    ),
  );

  getIt.registerFactory<GarageBloc>(
    () => GarageBloc(
      garageService: getIt<GarageService>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerFactory<EventsBloc>(
    () => EventsBloc(
      eventsService: getIt<EventsService>(),
    ),
  );

  getIt.registerFactory<CrewBloc>(
    () => CrewBloc(
      crewService: getIt<CrewService>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerFactory<MomentsBloc>(
    () => MomentsBloc(
      momentsService: getIt<MomentsService>(),
      sessionStorage: getIt<SessionStorage>(),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE BLOCS
  // ═══════════════════════════════════════════════════════════════════════════

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      usersService: getIt<UsersService>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );
}
