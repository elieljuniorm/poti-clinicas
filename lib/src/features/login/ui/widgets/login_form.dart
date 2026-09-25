// lib/src/features/login/ui/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../application/login_controller.dart';
import '../states/login_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  // Inicializando com valores vazios para evitar problemas de null safety
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Decoração padrão dos campos: pílula com borda verde-azulada.
  InputDecoration _decoracaoCampo({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.borderAccent, width: 2),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.formHint,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 15, right: 8),
        child: Icon(prefixIcon, color: AppColors.borderAccent),
      ),
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      border: borda,
      enabledBorder: borda,
      focusedBorder: borda,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state is LoginLoading;
    final errorState = state is LoginError ? state : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label EMAIL
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ), // empurra só o texto para a direita
            child: Text('EMAIL', style: AppTextStyles.formLabel),
          ),
          // Campo de Email
          TextField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: _decoracaoCampo(
              hint: 'Digite seu e-mail',
              prefixIcon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Label SENHA
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ), // empurra só o texto para a direita
            child: Text('SENHA', style: AppTextStyles.formLabel),
          ),
          const SizedBox(height: 8),
          // Campo de Senha
          TextField(
            controller: _passwordController,
            enabled: !isLoading,
            obscureText: _obscurePassword,
            decoration: _decoracaoCampo(
              hint: 'Digite sua senha',
              prefixIcon: Icons.key,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.borderAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botão Entrar
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              // ou Align(alignment: Alignment.center)
              child: SizedBox(
                width: 200, // largura real do botão
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref
                        .read(loginControllerProvider.notifier)
                        .entrar(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                  },
                  child: const Text('ENTRAR', style: AppTextStyles.buttonLabel),
                ),
              ),
            ),

          // Exibição de Erro (espaço sempre reservado)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Visibility(
              visible: errorState != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(
                errorState?.message ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
