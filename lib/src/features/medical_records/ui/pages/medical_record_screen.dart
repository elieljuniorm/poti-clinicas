import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_primary_button.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_section_divider.dart';
import '../../application/medical_record_controller.dart';
import '../../domain/models/medical_record_content.dart';
import '../../domain/models/medical_record_details_model.dart';
import '../states/medical_record_state.dart';
import '../widgets/evolution/evolution_details_modal.dart';
import '../widgets/evolution/new_evolution_modal.dart';
import '../widgets/record/discharge_card.dart';
import '../widgets/record/discharge_dialog.dart';
import '../widgets/record/latest_evolution_card.dart';
import '../widgets/record/medical_record_patient_card.dart';
import '../widgets/record/medical_record_section_card.dart';
import 'medical_record_body.dart';

/// Tela "Visualizar Prontuário": paciente, alta (ou o botão do protocolo
/// de alta), evolução mais recente e as seções do prontuário, cada uma com
/// o lápis para editar.
///
/// Prontuário fechado (alta) fica só para leitura: sem editar e sem
/// nova evolução.
class MedicalRecordScreen extends ConsumerWidget {
  final String patientId;

  const MedicalRecordScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DischargeState>(dischargeControllerProvider(patientId), (
      previous,
      next,
    ) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior.
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      if (next is DischargeSuccess) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Alta registrada. Prontuário fechado')),
        );
      }
      if (next is DischargeError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final state = ref.watch(medicalRecordControllerProvider(patientId));
    final registrandoAlta =
        ref.watch(dischargeControllerProvider(patientId)) is DischargeSaving;

    return AppScaffold(
      titulo: 'Visualizar Prontuário',
      rotaAtual: '/prontuario/registro',
      actions: const [AppBackButton(rotaAnterior: 'prontuario')],
      backgroundColor: AppColors.background,
      body: MedicalRecordBody(
        state: state,
        conteudo: (details) =>
            _conteudo(context, ref, details, registrandoAlta: registrandoAlta),
      ),
    );
  }

  Future<void> _registrarAlta(
    BuildContext context,
    WidgetRef ref,
    MedicalRecordDetailsModel details,
  ) async {
    final alta = await showDischargeDialog(
      context,
      paciente: details.summary.patientName,
    );
    if (alta == null) return;
    await ref
        .read(dischargeControllerProvider(patientId).notifier)
        .registrarAlta(motivo: alta.motivo, descricao: alta.descricao);
  }

  List<Widget> _conteudo(
    BuildContext context,
    WidgetRef ref,
    MedicalRecordDetailsModel details, {
    required bool registrandoAlta,
  }) {
    final record = details.record;
    final fechado = details.summary.discharged;
    final discharge = details.discharge;
    final parametros = {'patientId': patientId};

    return [
      MedicalRecordPatientCard(details: details),
      const SizedBox(height: 12),

      // ---------- Protocolo de alta ----------
      if (discharge != null) ...[
        const AppSectionDivider(titulo: 'ALTA'),
        DischargeCard(discharge: discharge),
        const SizedBox(height: 12),
      ] else if (!fechado && record != null) ...[
        _RegistrarAltaButton(
          carregando: registrandoAlta,
          onPressed: () => _registrarAlta(context, ref, details),
        ),
        const SizedBox(height: 12),
      ],

      // ---------- Evoluções ----------
      const AppSectionDivider(titulo: 'EVOLUÇÕES'),
      Row(
        children: [
          const Expanded(
            child: Text(
              'EVOLUÇÃO RECENTE',
              style: AppTextStyles.detailsSectionTitle,
            ),
          ),
          if (details.aberto)
            _NovaEvolucaoButton(
              onPressed: () => showNewEvolutionModal(
                context,
                patientId: patientId,
                numeroSessao: details.proximaSessao,
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      LatestEvolutionCard(
        evolution: details.latestEvolution,
        aoAbrir: (evolucao) => showEvolutionDetailsModal(context, evolucao),
      ),
      const SizedBox(height: 12),

      // ---------- Seções do prontuário ----------
      if (record != null)
        for (final secao in MedicalRecordSection.values) ...[
          AppSectionDivider(titulo: secao.label),
          MedicalRecordSectionCard(
            secao: secao,
            record: record,
            // O lápis abre a edição já na seção tocada.
            aoEditar: fechado
                ? null
                : () => context.goNamed(
                    'prontuario-editar',
                    pathParameters: parametros,
                    queryParameters: {'secao': secao.name},
                  ),
          ),
          const SizedBox(height: 12),
        ]
      else ...[
        const AppSectionDivider(titulo: 'PRONTUÁRIO'),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'O prontuário deste paciente ainda não foi criado',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        AppPrimaryButton(
          label: 'Criar Registro',
          onPressed: () =>
              context.goNamed('prontuario-criar', pathParameters: parametros),
        ),
      ],
    ];
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// "+ Nova Evolução": pílula verde-azulada ao lado do título.
class _NovaEvolucaoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NovaEvolucaoButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.borderAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          '+ Nova Evolução',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Abre o protocolo de alta: botão contornado, mais discreto que as
/// ações do dia a dia.
class _RegistrarAltaButton extends StatelessWidget {
  final bool carregando;
  final VoidCallback onPressed;

  const _RegistrarAltaButton({
    required this.carregando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const cor = AppColors.recordDischargedBackground;

    return SizedBox(
      height: 45,
      child: OutlinedButton.icon(
        onPressed: carregando ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cor,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: cor, width: 1.5),
          shape: const StadiumBorder(),
        ),
        icon: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: cor),
              )
            : const Icon(Symbols.assignment_turned_in, size: 20),
        label: const Text(
          'Registrar Alta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
