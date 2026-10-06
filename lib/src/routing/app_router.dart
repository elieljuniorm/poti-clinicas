import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/scheduling/ui/pages/new_appointment_screen.dart';
import '../features/scheduling/ui/pages/scheduling_screen.dart';
import '../features/finance/ui/pages/finance_screen.dart';
import '../features/finance/ui/pages/new_invoice_screen.dart';
import '../features/history/ui/pages/history_screen.dart';
import '../features/home/ui/pages/home_screen.dart';
import '../features/login/ui/pages/login_screen.dart';
import '../features/medical_records/domain/models/medical_record_content.dart';
import '../features/medical_records/ui/pages/medical_record_form_screen.dart';
import '../features/medical_records/ui/pages/medical_record_screen.dart';
import '../features/medical_records/ui/pages/medical_records_screen.dart';
import '../features/profile/ui/pages/profile_edit_screen.dart';
import '../features/profile/ui/pages/profile_screen.dart';
import '../features/splash/ui/pages/splash_screen.dart';
import '../features/users/ui/pages/user_edit_screen.dart';
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
        // Sub-rota: /usuario/:userId/editar. Aberta pelo card do topo do
        // modal do usuário.
        GoRoute(
          path: ':userId/editar',
          name:
              'usuario-editar', // ← usado por context.goNamed('usuario-editar')
          builder: (context, state) =>
              UserEditScreen(userId: state.pathParameters['userId']!),
        ),
      ],
    ),
    GoRoute(
      path: '/agenda',
      name: 'agenda',
      builder: (context, state) => const SchedulingScreen(),
      routes: [
        // Sub-rota: /agenda/novo. Aberta pelo card "Novo Atendimento".
        GoRoute(
          path: 'novo',
          name: 'agenda-novo', // usado por context.goNamed('agenda-novo')
          builder: (context, state) => const NewAppointmentScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/prontuario',
      name: 'prontuario',
      builder: (context, state) => const MedicalRecordsScreen(),
      routes: [
        // Sub-rotas do prontuário do paciente.
        GoRoute(
          path: ':patientId/novo',
          name: 'prontuario-criar', // "Criar Registro"
          builder: (context, state) => MedicalRecordFormScreen(
            patientId: state.pathParameters['patientId']!,
          ),
        ),
        GoRoute(
          path: ':patientId',
          name: 'prontuario-registro', // "Ver / Editar Registro"
          builder: (context, state) => MedicalRecordScreen(
            patientId: state.pathParameters['patientId']!,
          ),
          // Sub-rota: o voltar da edição retorna à visualização.
          routes: [
            GoRoute(
              path: 'editar',
              name: 'prontuario-editar', // lápis da anamnese
              builder: (context, state) => MedicalRecordFormScreen(
                patientId: state.pathParameters['patientId']!,
                edicao: true,
                secao: MedicalRecordSection.values
                    .asNameMap()[state.uri.queryParameters['secao']],
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/historico',
      name: 'historico',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/financeiro',
      name: 'financeiro',
      builder: (context, state) => const FinanceScreen(),
      routes: [
        // Sub-rota: /financeiro/novo. Fatura sem atendimento: as sessões
        // viram créditos de agendamento do paciente.
        GoRoute(
          path: 'novo',
          name: 'financeiro-novo', // ← card "Novo Lançamento"
          builder: (context, state) => const NewInvoiceScreen(),
        ),
        // Sub-rota: /financeiro/pre-fatura/:id. Finaliza a pré-fatura
        // gerada pelo "Novo Atendimento" da Agenda.
        GoRoute(
          path: 'pre-fatura/:preInvoiceId',
          name: 'financeiro-pre-fatura', // ← card da pré-fatura
          builder: (context, state) => NewInvoiceScreen(
            preInvoiceId: state.pathParameters['preInvoiceId'],
          ),
        ),
      ],
    ),
  ],
);
