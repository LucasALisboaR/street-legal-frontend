import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearhead_br/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gearhead_br/features/auth/domain/repositories/auth_repository.dart';
import 'package:gearhead_br/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/login_usecase.dart';
import 'package:gearhead_br/features/auth/domain/usecases/register_usecase.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/login_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/register_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>()),
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
}

