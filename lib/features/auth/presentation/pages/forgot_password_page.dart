import 'package:flutter/material.dart';
import 'package:gearhead_br/core/theme/app_colors.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_button.dart';
import 'package:gearhead_br/features/auth/presentation/widgets/neon_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de Recuperação de Senha
/// TODO: Implementar BLoC completo
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: AppColors.accent.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
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
                
                // Campo de e-mail
                NeonTextField(
                  labelText: 'E-mail',
                  hintText: 'seu@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 32),
                
                // Botão enviar
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'ENVIAR LINK',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      // Mostrar diálogo de sucesso
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.darkGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 48,
                            ),
                          ),
                          title: Text(
                            'E-mail enviado!',
                            style: GoogleFonts.orbitron(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              color: AppColors.lightGrey,
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            SizedBox(
                              width: double.infinity,
                              child: NeonButton(
                                text: 'VOLTAR AO LOGIN',
                                height: 48,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
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
                        child: Text(
                          'Entrar',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

