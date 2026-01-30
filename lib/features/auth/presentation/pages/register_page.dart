import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/di/injection.dart';
import 'package:gearhead_br/core/router/app_router.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/auth/presentation/bloc/register_bloc.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de Registro do GEARHEAD BR
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          // Navegar para a tela principal após registro bem sucedido
          context.go(AppRouter.map);
        } else if (state.status == RegisterStatus.failure) {
          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(state.errorMessage ?? 'Erro ao criar conta'),
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
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.white, AppColors.accent],
                    ).createShader(bounds),
                    child: Text(
                      'CRIAR CONTA',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Junte-se à comunidade GEARHEAD',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: AppColors.lightGrey,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Formulário
                  _buildRegisterForm(),
                  
                  const SizedBox(height: 32),
                  
                  // Link para login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já tem uma conta? ',
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

  Widget _buildRegisterForm() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bloc = context.read<RegisterBloc>();
        final isLoading = state.status == RegisterStatus.loading;

        return Column(
          children: [
            // Nome
            NeonTextField(
              labelText: 'Nome completo',
              hintText: 'Como você quer ser chamado',
              prefixIcon: Icons.person_outline,
              enabled: !isLoading,
              onChanged: (value) => bloc.add(RegisterNameChanged(value)),
            ),
            
            const SizedBox(height: 20),
            
            // E-mail
            NeonTextField(
              labelText: 'E-mail',
              hintText: 'seu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: state.emailError,
              enabled: !isLoading,
              onChanged: (value) => bloc.add(RegisterEmailChanged(value)),
            ),
            
            const SizedBox(height: 20),
            
            // Senha
            NeonTextField(
              labelText: 'Senha',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline,
              obscureText: !state.isPasswordVisible,
              errorText: state.passwordError,
              enabled: !isLoading,
              onChanged: (value) => bloc.add(RegisterPasswordChanged(value)),
              suffixIcon: IconButton(
                icon: Icon(
                  state.isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.lightGrey,
                ),
                onPressed: () =>
                    bloc.add(const RegisterPasswordVisibilityToggled()),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Confirmar senha
            NeonTextField(
              labelText: 'Confirmar senha',
              hintText: 'Digite a senha novamente',
              prefixIcon: Icons.lock_outline,
              obscureText: !state.isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              errorText: state.confirmPasswordError,
              enabled: !isLoading,
              onChanged: (value) =>
                  bloc.add(RegisterConfirmPasswordChanged(value)),
              onEditingComplete: () {
                if (state.canSubmit) {
                  bloc.add(const RegisterSubmitted());
                }
              },
              suffixIcon: IconButton(
                icon: Icon(
                  state.isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.lightGrey,
                ),
                onPressed: () => bloc.add(
                  const RegisterConfirmPasswordVisibilityToggled(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Termos
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: state.termsAccepted,
                    onChanged: isLoading
                        ? null
                        : (value) => bloc.add(
                              RegisterTermsAcceptedChanged(value ?? false),
                            ),
                    activeColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.mediumGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.lightGrey,
                      ),
                      children: const [
                        TextSpan(text: 'Ao criar uma conta, você concorda com os '),
                        TextSpan(
                          text: 'Termos de Uso',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' e '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botão criar conta
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'CRIAR CONTA',
                icon: Icons.person_add_outlined,
                isLoading: isLoading,
                isEnabled: state.canSubmit,
                onPressed: () => bloc.add(const RegisterSubmitted()),
              ),
            ),
          ],
        );
      },
    );
  }
}

