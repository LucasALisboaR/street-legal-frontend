import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_theme.dart';
import 'package:gearhead_br/core/theme/ios_design_system.dart';
import 'package:gearhead_br/core/constants/mapbox_constants.dart';
import 'firebase_options.dart';

/// GEARHEAD BR - Rede social para entusiastas automotivos
/// 
/// Desenvolvido com Flutter, seguindo Clean Architecture
/// State Management: BLoC
/// Navigation: GoRouter
/// DI: GetIt
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (apenas se ainda não foi inicializado)
  // Isso evita erro durante hot reload ou se o Android inicializar automaticamente
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Configurar orientação da tela (portrait apenas)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar estilo da status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Inicializar Mapbox com o access token
  MapboxOptions.setAccessToken(MapboxConstants.accessToken);
  
  // Inicializar injeção de dependências
  await configureDependencies();
  
  runApp(const GearheadApp());
}

/// Widget raiz da aplicação
class GearheadApp extends StatelessWidget {
  const GearheadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GEARHEAD BR',
      debugShowCheckedModeBanner: false,
      
      // Tema dark customizado
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // Configuração de rotas
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return CupertinoTheme(
          data: IosDesignSystem.cupertinoTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
