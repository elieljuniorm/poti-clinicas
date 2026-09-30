import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_action_card.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_segmented_control.dart';
import '../../../../core/ui/widgets/app_status_legend.dart';
import '../../application/scheduling_controller.dart';
import '../../domain/models/scheduling_period.dart';
import '../states/scheduling_state.dart';
import '../widgets/scheduling_appointments_table.dart';

class SchedulingScreen extends ConsumerWidget {
  const SchedulingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulingState = ref.watch(schedulingControllerProvider);

    return AppScaffold(
      titulo: 'Agenda',
      rotaAtual: '/agenda',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Text(
                    'CONFIRA ABAIXO TODOS OS ATENDIMENTOS AGENDADOS\nCOM HORÁRIO E STATUS',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageDescription,
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppActionCard(
                    titulo: 'Novo Atendimento',
                    descricao:
                        'Agende atendimentos e crie vínculo de profissional',
                    onTap: () => context.goNamed('agenda-novo'),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSegmentedControl<SchedulingPeriod>(
                    opcoes: SchedulingPeriod.values,
                    rotulo: (periodo) => periodo.label,
                    selecionado: schedulingState.period,
                    aoSelecionar: ref
                        .read(schedulingControllerProvider.notifier)
                        .selecionarPeriodo,
                  ),
                ),
                const SizedBox(height: 12),

                const AppStatusLegend(),
                const SizedBox(height: 16),

                // Só a tabela mostra loading/erro: o filtro continua visível.
                _buildTabela(schedulingState),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabela(SchedulingState schedulingState) {
    if (schedulingState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (schedulingState.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Text(schedulingState.errorMessage!, textAlign: TextAlign.center),
      );
    }

    return SchedulingAppointmentsTable(
      appointments: schedulingState.appointments,
    );
  }
}
