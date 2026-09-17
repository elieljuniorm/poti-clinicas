// lib/src/features/splash/ui/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 🔹 Ajuste os caminhos conforme seus arquivos em assets/
  static const String _backgroundImage =
      'assets/fundo-img.png'; // fundo (cobre tudo)
  static const String _centerImage =
      'assets/logo-abertura.png'; // centro (média)
  static const String _bottomImage =
      'assets/le-poti-branca.png'; // bottom (menor)

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade: opacidade de 0 → 1 com curva suave
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Scale: começa em 1.15 (um pouco maior) e vai para 1.0 (tamanho normal)
    _scaleAnimation = Tween<double>(
      begin: 1.15,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(210, 221, 225, 1),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // CAMADA 1 — FUNDO
              Image.asset(_backgroundImage, fit: BoxFit.cover),

              // CAMADA 2 — CENTRO
              Center(
                child: Image.asset(
                  _centerImage,
                  width: screenWidth * 70,
                  fit: BoxFit.cover,
                ),
              ),

              // CAMADA 3 — RODAPÉ
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Image.asset(
                    _bottomImage,
                    fit: BoxFit.cover,
                    width: 187,
                    height: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
