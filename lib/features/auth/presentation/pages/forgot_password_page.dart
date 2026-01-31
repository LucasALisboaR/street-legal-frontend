import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/core/widgets/app_icon_button.dart';
import 'package:gearhead_br/core/widgets/app_modal.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de Recuperação de Senha do GEARHEAD BR
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ForgotPasswordBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          // Mostrar diálogo de sucesso
          AppModal.show<void>(
            context: context,
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'E-mail enviado!',
                  style: GoogleFonts.orbitron(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
              textAlign: TextAlign.center,
            ),
            actions: [
              AppModal.action(
                label: 'Voltar ao login',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
              ),
            ],
          );
        } else if (state.status == ForgotPasswordStatus.failure) {
          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(state.errorMessage ?? 'Erro ao enviar e-mail'),
                  ),
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
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Botão voltar
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => context.pop(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Ícone
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkGrey,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.white, AppColors.accent],
                      ).createShader(bounds),
                      child: Text(
                        'RECUPERAR SENHA',
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Center(
                    child: Text(
                      'Digite seu e-mail e enviaremos um link\npara redefinir sua senha',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        color: AppColors.lightGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Formulário
                  _buildForgotPasswordForm(),
                  
                  const SizedBox(height: 32),
                  
                  // Link para login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lembrou a senha? ',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.lightGrey,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentLight],
                            ).createShader(bounds),
                            child: Text(
                              'Entrar',
                              style: GoogleFonts.rajdhani(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        final bloc = context.read<ForgotPasswordBloc>();
        final isLoading = state.status == ForgotPasswordStatus.loading;

        return Column(
          children: [
            // Campo de e-mail
            NeonTextField(
              labelText: 'E-mail',
              hintText: 'seu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              errorText: state.emailError,
              enabled: !isLoading,
              onChanged: (value) =>
                  bloc.add(ForgotPasswordEmailChanged(value)),
              onEditingComplete: () {
                if (state.canSubmit) {
                  bloc.add(const ForgotPasswordSubmitted());
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            // Botão enviar
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'ENVIAR LINK',
                icon: Icons.send_rounded,
                isLoading: isLoading,
                isEnabled: state.canSubmit,
                onPressed: () => bloc.add(const ForgotPasswordSubmitted()),
              ),
            ),
          ],
        );
      },
    );
  }
}
