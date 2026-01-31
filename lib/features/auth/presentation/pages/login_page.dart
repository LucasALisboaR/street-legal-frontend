import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/login_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/animated_logo.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de Login do GEARHEAD BR
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          // Navegar para a garagem após login bem sucedido
          context.go(AppRouter.map);
        } else if (state.status == LoginStatus.failure) {
          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.errorMessage ?? 'Erro ao fazer login')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A1A),
                AppColors.black,
                AppColors.black,
              ],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // ═══════════════════════════════════════════════════════
                      // LOGO E TÍTULO
                      // ═══════════════════════════════════════════════════════
                      const AnimatedLogo(),
                      const SizedBox(height: 24),
                      
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.white, AppColors.accent],
                        ).createShader(bounds),
                        child: Text(
                          'GEARHEAD BR',
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'A comunidade que acelera junto',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: AppColors.lightGrey,
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // ═══════════════════════════════════════════════════════
                      // FORMULÁRIO
                      // ═══════════════════════════════════════════════════════
                      _buildLoginForm(),
                      
                      const SizedBox(height: 40),
                      
                      // ═══════════════════════════════════════════════════════
                      // CRIAR CONTA
                      // ═══════════════════════════════════════════════════════
                      _buildCreateAccountLink(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();
        final isLoading = state.status == LoginStatus.loading;

        return Column(
          children: [
            // E-mail
            NeonTextField(
              labelText: 'E-mail',
              hintText: 'seu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: state.emailError,
              enabled: !isLoading,
              onChanged: (value) => bloc.add(LoginEmailChanged(value)),
            ),
            
            const SizedBox(height: 20),
            
            // Senha
            NeonTextField(
              labelText: 'Senha',
              hintText: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: !state.isPasswordVisible,
              textInputAction: TextInputAction.done,
              errorText: state.passwordError,
              enabled: !isLoading,
              onChanged: (value) => bloc.add(LoginPasswordChanged(value)),
              onEditingComplete: () {
                if (state.canSubmit) {
                  bloc.add(const LoginSubmitted());
                }
              },
              suffixIcon: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => bloc.add(const LoginPasswordVisibilityToggled()),
                child: Icon(
                  state.isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.lightGrey,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Esqueci minha senha
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: isLoading
                    ? null
                    : () => context.push(AppRouter.forgotPassword),
                child: Text(
                  'Esqueci minha senha',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão de login
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'ENTRAR',
                icon: Icons.login_rounded,
                isLoading: isLoading,
                isEnabled: state.canSubmit,
                onPressed: () => bloc.add(const LoginSubmitted()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: GoogleFonts.rajdhani(
            color: AppColors.lightGrey,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRouter.register),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight],
            ).createShader(bounds),
            child: Text(
              'Criar conta',
              style: GoogleFonts.rajdhani(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
