import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_financial_summary_card.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_segmented_control.dart';
import '../../../home/ui/widgets/financial_entry_card.dart';
import '../../application/history_controller.dart';
import '../../domain/models/history_tab.dart';
import '../states/history_state.dart';
import '../widgets/appointment_history_card.dart';

/// Histórico: atendimentos e lançamentos financeiros, escolhidos
/// no seletor do topo.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);

    return AppScaffold(
      titulo: 'Histórico',
      rotaAtual: '/historico',
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
                AppSegmentedControl<HistoryTab>(
                  opcoes: HistoryTab.values,
                  rotulo: (aba) => aba.label,
                  selecionado: historyState.tab,
                  aoSelecionar: controller.selecionarAba,
                ),
                const SizedBox(height: 24),

                // Só o conteúdo mostra loading/erro: o seletor continua visível.
                _buildConteudo(historyState, controller),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo(HistoryState state, HistoryController controller) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(state.errorMessage!, textAlign: TextAlign.center),
      );
    }

    return switch (state.tab) {
      HistoryTab.appointments => _Atendimentos(state: state),
      HistoryTab.entries => _Lancamentos(
        state: state,
        aoVerTodos: controller.alternarTodosLancamentos,
      ),
    };
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Atendimentos extends StatelessWidget {
  final HistoryState state;

  const _Atendimentos({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.appointments.isEmpty) {
      return const _Vazio(texto: 'Nenhum atendimento no histórico');
    }

    return Column(
      children: [
        for (final atendimento in state.appointments)
          AppointmentHistoryCard(appointment: atendimento),
      ],
    );
  }
}

class _Lancamentos extends StatelessWidget {
  final HistoryState state;
  final VoidCallback aoVerTodos;

  const _Lancamentos({required this.state, required this.aoVerTodos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFinancialSummaryCard(
          titulo: 'TOTAL A RECEBER',
          total: state.overview.total,
          recebido: state.overview.received,
          pendente: state.overview.pending,
        ),
        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: Text(
                state.showAllEntries
                    ? 'TODOS OS LANÇAMENTOS'
                    : 'LANÇAMENTOS RECENTES',
                style: AppTextStyles.detailsSectionTitle,
              ),
            ),
            if (state.hasMoreEntries)
              TextButton(
                onPressed: aoVerTodos,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.borderAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(state.showAllEntries ? 'Ver Menos' : 'Ver Todos'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.entries.isEmpty)
          const _Vazio(texto: 'Nenhum lançamento no histórico')
        else
          for (final lancamento in state.visibleEntries)
            FinancialEntryCard(item: lancamento),
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  final String texto;

  const _Vazio({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
