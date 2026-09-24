import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../auth/application/auth_controller.dart';
import '../widgets/controllers/home_controller.dart';
import '../widgets/daily_appointments_widget.dart';
import '../widgets/evolutions_widget.dart';
import '../widgets/financial_summary_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider);
    final homeState = ref.watch(homeControllerProvider);

    return AppScaffold(
      titulo: 'Bem-vindo(a)',
      rotaAtual: '/home',
      backgroundColor: const Color.fromRGBO(210, 221, 225, 1),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.errorMessage != null
          ? Center(child: Text(homeState.errorMessage!))
          : _buildBody(homeState, usuario?.name),
    );
  }

  // Status atendimentos: Confirmado, Pendente, Cancelado
  Widget _buildLegendItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(dynamic homeState, String? nomeUsuario) {
    const backgroundColor = Color(0xFFF2F2F7);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        // O conteúdo começa IMEDIATAMENTE no topo do container cinza.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção 1: Atendimentos do Dia
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Center(
                  child: Text(
                    'ATENDIMENTOS DO DIA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F4C5C),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'CONFIRA ABAIXO TODOS OS ATENDIMENTOS AGENDADOS\nPARA HOJE, COM HORÁRIO E STATUS ATUALIZADOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      Icons.check_circle_outline,
                      'Confirmado',
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      Icons.brightness_1_outlined,
                      'Pendente',
                      Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      Icons.cancel_outlined,
                      'Cancelado',
                      Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              DailyAppointmentsWidget(
                appointments: homeState.dailyAppointments,
              ),
              const SizedBox(height: 24),

              // Seção 2: Evoluções
              const Center(
                child: Text(
                  'EVOLUÇÕES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F4C5C),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Center(
                  child: Text(
                    'CONFIRA ABAIXO AS EVOLUÇÕES DO DIA',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              EvolutionsWidget(evolutions: homeState.evolutions),
              const SizedBox(height: 24),

              // Seção 3: Resumo Financeiro
              const Center(
                child: Text(
                  'ATENDIMENTOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F4C5C),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Center(
                  child: Text(
                    'RESUMO MENSAL DE ATENDIMENTOS REALIZADOS',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              FinancialSummaryWidget(summaries: homeState.financialSummaries),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
