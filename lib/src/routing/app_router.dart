import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/ui/pages/home_screen.dart';
import '../features/login/ui/pages/login_screen.dart';
import '../features/splash/ui/pages/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',                     // ← usado por context.goNamed('login')
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',                      // ← usado por context.goNamed('home')
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);