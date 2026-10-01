import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_filter_chips.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_search_field.dart';
import '../../application/medical_records_controller.dart';
import '../../domain/models/medical_record_filter.dart';
import '../states/medical_records_state.dart';
import '../widgets/medical_record_card.dart';

/// Lista de pacientes com a situação do prontuário de cada um.
class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsState = ref.watch(medicalRecordsControllerProvider);
    final controller = ref.read(medicalRecordsControllerProvider.notifier);

    return AppScaffold(
      titulo: 'Prontuário',
      rotaAtual: '/prontuario',
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
            // Arrastar a lista fecha o teclado da busca.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchField(
                  dica: 'Buscar paciente pelo nome',
                  aoBuscar: controller.buscar,
                ),
                const SizedBox(height: 16),

                AppFilterChips<MedicalRecordFilter>(
                  opcoes: MedicalRecordFilter.values,
                  rotulo: (filtro) => filtro.label,
                  selecionado: recordsState.filter,
                  aoSelecionar: controller.selecionarFiltro,
                ),
                const SizedBox(height: 16),

                // Só a lista mostra loading/erro: busca e filtro continuam visíveis.
                _buildLista(context, recordsState),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, MedicalRecordsState recordsState) {
    if (recordsState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (recordsState.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(recordsState.errorMessage!, textAlign: TextAlign.center),
      );
    }

    final prontuarios = recordsState.filteredRecords;
    if (prontuarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'Nenhum paciente encontrado',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: prontuarios.length,
      itemBuilder: (context, index) {
        final prontuario = prontuarios[index];
        final parametros = {'patientId': prontuario.patientId};
        return MedicalRecordCard(
          record: prontuario,
          aoCriar: () =>
              context.goNamed('prontuario-criar', pathParameters: parametros),
          aoAbrir: () => context.goNamed(
            'prontuario-registro',
            pathParameters: parametros,
          ),
        );
      },
    );
  }
}
