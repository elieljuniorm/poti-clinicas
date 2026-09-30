import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_status_legend.dart';
import '../../application/home_controller.dart';
import '../states/home_state.dart';
import '../widgets/daily_appointments_widget.dart';
import '../widgets/evolutions_widget.dart';
import '../widgets/financial_summary_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

    return AppScaffold(
      titulo: 'Bem-vindo(a)',
      rotaAtual: '/home',
      backgroundColor: AppColors.background,
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.errorMessage != null
          ? Center(child: Text(homeState.errorMessage!))
          : _buildBody(homeState),
    );
  }

  Widget _buildBody(HomeState homeState) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: AppColors.surfaceMuted,
        width: double.infinity,
        // O conteúdo começa IMEDIATAMENTE no topo do container cinza.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção 1: Atendimentos do Dia
              const _TituloSecao(
                titulo: 'ATENDIMENTOS DO DIA',
                subtitulo: 'CONFIRA ABAIXO TODOS OS ATENDIMENTOS AGENDADOS\nPARA HOJE, COM HORÁRIO E STATUS ATUALIZADOS',
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                espaco: 8,
              ),
              const SizedBox(height: 12),

              const AppStatusLegend(),
              const SizedBox(height: 16),

              DailyAppointmentsWidget(
                appointments: homeState.dailyAppointments,
              ),
              const SizedBox(height: 24),

              // Seção 2: Evoluções
              const _TituloSecao(
                titulo: 'EVOLUÇÕES',
                subtitulo: 'CONFIRA ABAIXO AS EVOLUÇÕES DO DIA',
              ),
              const SizedBox(height: 12),

              EvolutionsWidget(evolutions: homeState.evolutions),
              const SizedBox(height: 24),

              // Seção 3: Resumo Financeiro
              const _TituloSecao(
                titulo: 'ATENDIMENTOS',
                subtitulo: 'RESUMO MENSAL DE ATENDIMENTOS REALIZADOS',
              ),
              const SizedBox(height: 12),

              FinancialSummaryWidget(summaries: homeState.financialSummaries),
              // Espaço para o menu inferior flutuante
              const AppBottomSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Título centralizado de seção + subtítulo cinza.
class _TituloSecao extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final EdgeInsetsGeometry padding;

  /// Espaço entre título e subtítulo.
  final double espaco;

  const _TituloSecao({
    required this.titulo,
    required this.subtitulo,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 4),
    this.espaco = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: espaco),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionSubtitle,
          ),
        ],
      ),
    );
  }
}
