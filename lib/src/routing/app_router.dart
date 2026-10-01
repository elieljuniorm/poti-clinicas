import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/pages/em_construcao_screen.dart';
import '../features/scheduling/ui/pages/scheduling_screen.dart';
import '../features/home/ui/pages/home_screen.dart';
import '../features/login/ui/pages/login_screen.dart';
import '../features/medical_records/ui/pages/medical_records_screen.dart';
import '../features/profile/ui/pages/profile_edit_screen.dart';
import '../features/profile/ui/pages/profile_screen.dart';
import '../features/splash/ui/pages/splash_screen.dart';
import '../features/users/ui/pages/user_registration_screen.dart';
import '../features/users/ui/pages/users_screen.dart';

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
      name: 'login', // ← usado por context.goNamed('login')
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
      name: 'home', // usado por context.goNamed('home')
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile', // aberta pelo cabeçalho do Drawer (foto + saudação)
      builder: (context, state) => const ProfileScreen(),
      routes: [
        // Sub-rota: /profile/edit. O "voltar" do sistema retorna ao perfil.
        GoRoute(
          path: 'edit',
          name: 'profile-edit', // ← usado por context.goNamed('profile-edit')
          builder: (context, state) => const ProfileEditScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/usuario',
      name: 'usuario',
      builder: (context, state) => const UsersScreen(),
      routes: [
        // Sub-rota: /usuario/novo. Aberta só pelo card "Cadastrar Usuário".
        GoRoute(
          path: 'novo',
          name: 'usuario-novo', // ← usado por context.goNamed('usuario-novo')
          builder: (context, state) => const UserRegistrationScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/agenda',
      name: 'agenda',
      builder: (context, state) => const SchedulingScreen(),
      routes: [
        // Sub-rota: /agenda/novo. Troque pela tela real de novo atendimento.
        GoRoute(
          path: 'novo',
          name: 'agenda-novo', // usado por context.goNamed('agenda-novo')
          builder: (context, state) => const EmConstrucaoScreen(
            titulo: 'Novo Atendimento',
            rotaAtual: '/agenda/novo',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/prontuario',
      name: 'prontuario',
      builder: (context, state) => const MedicalRecordsScreen(),
      routes: [
        // Sub-rotas do registro do paciente. Troque pelas telas reais.
        GoRoute(
          path: ':patientId/novo',
          name: 'prontuario-criar', // "Criar Registro"
          builder: (context, state) => const EmConstrucaoScreen(
            titulo: 'Cadastrar Prontuário',
            rotaAtual: '/prontuario/novo',
          ),
        ),
        GoRoute(
          path: ':patientId',
          name: 'prontuario-registro', // "Ver / Editar Registro"
          builder: (context, state) => const EmConstrucaoScreen(
            titulo: 'Visualizar Prontuário',
            rotaAtual: '/prontuario/registro',
          ),
        ),
      ],
    ),

    // ---------- Rotas do menu ainda sem feature própria ----------
    // Troque o builder pela tela real quando a feature for criada.
    GoRoute(
      path: '/historico',
      name: 'historico',
      builder: (context, state) => const EmConstrucaoScreen(
        titulo: 'Histórico',
        rotaAtual: '/historico',
      ),
    ),
    GoRoute(
      path: '/financeiro',
      name: 'financeiro',
      builder: (context, state) => const EmConstrucaoScreen(
        titulo: 'Financeiro',
        rotaAtual: '/financeiro',
      ),
    ),
  ],
);
