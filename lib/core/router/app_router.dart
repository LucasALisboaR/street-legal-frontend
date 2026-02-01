import 'package:flutter/material.dart';
import 'package:gearhead_br/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:gearhead_br/features/auth/presentation/pages/login_page.dart';
import 'package:gearhead_br/features/auth/presentation/pages/register_page.dart';
import 'package:gearhead_br/features/crew/presentation/pages/crew_page.dart';
import 'package:gearhead_br/features/events/presentation/pages/events_page.dart';
import 'package:gearhead_br/features/map/presentation/pages/map_page.dart';
import 'package:gearhead_br/features/moments/presentation/pages/moments_page.dart';
import 'package:gearhead_br/features/profile/presentation/pages/profile_page.dart';
import 'package:gearhead_br/features/garage/presentation/pages/garage_management_page.dart';
import 'package:go_router/go_router.dart';

/// Configuração de rotas do GEARHEAD BR
/// Utiliza GoRouter para navegação declarativa
class AppRouter {
  AppRouter._();

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTE NAMES
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main Navigation
  static const String map = '/';  // Tela principal
  static const String crew = '/crew';
  static const String events = '/events';
  static const String moments = '/moments';
  static const String profile = '/profile';
  static const String garageManagement = '/garage-management';

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTER CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    
    routes: [
      // ─────────────────────────────────────────────────────────────────────────
      // AUTH ROUTES
      // ─────────────────────────────────────────────────────────────────────────
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),
      
      // ─────────────────────────────────────────────────────────────────────────
      // MAIN NAVIGATION ROUTES
      // ─────────────────────────────────────────────────────────────────────────
      GoRoute(
        path: map,
        name: 'map',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MapPage(),
        ),
      ),
      GoRoute(
        path: crew,
        name: 'crew',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const CrewPage(),
        ),
      ),
      GoRoute(
        path: events,
        name: 'events',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const EventsPage(),
        ),
      ),
      GoRoute(
        path: moments,
        name: 'moments',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MomentsPage(),
        ),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: garageManagement,
        name: 'garageManagement',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const GarageManagementPage(),
        ),
      ),
    ],
    
    // ─────────────────────────────────────────────────────────────────────────
    // ERROR PAGE
    // ─────────────────────────────────────────────────────────────────────────
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(map),
                child: const Text('VOLTAR'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Transição customizada com fade
  static CustomTransitionPage<void> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
