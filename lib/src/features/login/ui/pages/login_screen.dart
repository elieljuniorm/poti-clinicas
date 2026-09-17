// lib/src/features/login/ui/pages/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/login_controller.dart';
import '../states/login_state.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next is LoginSuccess) {
        context.goNamed('home');
      }
      if (next is LoginError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromRGBO(
        210,
        221,
        225,
        1,
      ), // Fundo azul claro atrás da imagem
      body: SafeArea(
        bottom: false, // Permite que o card branco vá até o final da tela
        child: Column(
          children: [
            // ============ ÁREA DO TOPO (IMAGEM) ============
            Expanded(
              flex: 3,
              child: Image.asset(
                'assets/fundo-login.png',
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // 90% da largura da tela
                fit: BoxFit.fitWidth, // Ajusta a imagem sem cortar
                alignment: Alignment.bottomCenter, // Alinha na base
              ),
            ),

            // ============ ÁREA DO FORMULÁRIO (CARD BRANCO) ============
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      const LoginForm(),
                      const SizedBox(height: 8),
                      // ============ RODAPÉ (LOGO LE POTI TECH) ============
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Image.asset(
                          'assets/footer_lepotitech.png',
                          fit: BoxFit.cover,
                          width: 187,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
