import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_action_card.dart';
import '../../../../core/ui/widgets/app_area_chart.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_financial_summary_card.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/finance_controller.dart';
import '../../domain/models/finance_dashboard_model.dart';
import '../states/finance_state.dart';
import '../widgets/professional_payout_card.dart';

/// Financeiro: novo lançamento (fatura do paciente), faturamento do mês,
/// gráfico da semana e repasse por profissional.
class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeControllerProvider);
    final controller = ref.read(financeControllerProvider.notifier);

    return AppScaffold(
      titulo: 'Financeiro',
      rotaAtual: '/financeiro',
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppActionCard(
                  titulo: 'Novo Lançamento',
                  descricao:
                      'Cadastre uma nova fatura preenchendo os dados do '
                      'cliente e valores',
                  onTap: () => context.goNamed('financeiro-novo'),
                ),
                const SizedBox(height: 20),

                // Só o painel mostra loading/erro: o "Novo Lançamento"
                // continua disponível.
                _buildPainel(financeState, controller),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPainel(FinanceState state, FinanceController controller) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final painel = state.dashboard;
    if (state.errorMessage != null || painel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          state.errorMessage ?? 'Sem dados financeiros',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFinancialSummaryCard(
          titulo: 'FATURAMENTO DO MÊS',
          total: painel.monthTotal,
          recebido: painel.monthReceived,
          pendente: painel.monthPending,
        ),
        const SizedBox(height: 28),

        _GraficoSemana(painel: painel),
        const SizedBox(height: 32),

        _Profissionais(
          state: state,
          aoVerTodos: controller.alternarTodosProfissionais,
        ),
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _GraficoSemana extends StatelessWidget {
  final FinanceDashboardModel painel;

  const _GraficoSemana({required this.painel});

  @override
  Widget build(BuildContext context) {
    if (painel.week.isEmpty) return const SizedBox.shrink();

    return AppAreaChart(
      descricao: 'Faturamento da semana',
      pontos: [
        for (final dia in painel.week) AppChartPoint(dia.day, dia.amount),
      ],
    );
  }
}

class _Profissionais extends StatelessWidget {
  final FinanceState state;
  final VoidCallback aoVerTodos;

  const _Profissionais({required this.state, required this.aoVerTodos});

  @override
  Widget build(BuildContext context) {
    final profissionais = state.visibleProfessionals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROFISSIONAIS',
                    style: AppTextStyles.detailsSectionTitle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Resumo de lançamentos por atendimento',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            if (state.hasMoreProfessionals)
              TextButton(
                onPressed: aoVerTodos,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.borderAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  // Parte do estilo do tema para manter a fonte do app.
                  textStyle: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  state.showAllProfessionals ? 'Ver Menos' : 'Ver Todos',
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (profissionais.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Nenhum lançamento de profissional no período',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          )
        else
          for (final profissional in profissionais)
            ProfessionalPayoutCard(payout: profissional),
      ],
    );
  }
}
