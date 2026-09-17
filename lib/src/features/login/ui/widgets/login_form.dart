// lib/src/features/login/ui/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Cores baseadas na imagem
  final Color _primaryColor = const Color.fromRGBO(
    0,
    121,
    107,
    1,
  ); // Verde escuro do botão
  final Color _borderColor = const Color.fromRGBO(
    25,
    126,
    144,
    1,
  ); // Verde/Teal das bordas
  final Color _textColor = const Color.fromRGBO(
    0,
    0,
    0,
    1,
  ); // Cinza escuro do texto

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state is LoginLoading;
    final errorState = state is LoginError ? state : null; // 👈 NOVO

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
            child: Text(
              'EMAIL',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          // Campo de Email
          TextField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Digite seu e-mail',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                color: const Color(0xFF9E9E9E),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 8),
                child: Icon(Icons.email_outlined, color: _borderColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Label SENHA
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ), // empurra só o texto para a direita
            child: Text(
              'SENHA',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Campo de Senha
          TextField(
            controller: _passwordController,
            enabled: !isLoading,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Digite sua senha',
              hintStyle: TextStyle(
                color: const Color(0xFF9E9E9E),
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 8),
                child: Icon(Icons.key, color: _borderColor),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _borderColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
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
                    backgroundColor: _primaryColor,
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
                  child: const Text(
                    'ENTRAR',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
