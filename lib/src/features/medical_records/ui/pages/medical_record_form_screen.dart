import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/evolution_controller.dart';
import '../../application/medical_record_controller.dart';
import '../../domain/models/medical_record_content.dart';
import '../states/medical_record_state.dart';
import '../widgets/record/medical_record_form.dart';
import '../widgets/record/medical_record_patient_card.dart';
import 'medical_record_body.dart';

/// Telas "Cadastrar Prontuário" e "Editar Prontuário": o mesmo
/// formulário, aberto pelo "Criar Registro" da lista ou pelo lápis da
/// visualização. Salvar leva para a visualização, já com o status novo.
class MedicalRecordFormScreen extends ConsumerWidget {
  final String patientId;

  /// Aberta pelo lápis (edição). O formulário segue o que veio da API: um
  /// paciente que já tem prontuário sempre edita.
  final bool edicao;

  /// Seção do lápis tocado: a edição abre rolada até ela.
  final MedicalRecordSection? secao;

  const MedicalRecordFormScreen({
    super.key,
    required this.patientId,
    this.edicao = false,
    this.secao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parametros = {'patientId': patientId};
    void abrirProntuario() =>
        context.goNamed('prontuario-registro', pathParameters: parametros);
    // Cancelar volta de onde veio: a visualização (edição) ou a lista.
    void cancelar() =>
        edicao ? abrirProntuario() : context.goNamed('prontuario');

    ref.listen<MedicalRecordFormState>(
      medicalRecordFormControllerProvider(patientId),
      (previous, next) {
        // hideCurrentSnackBar: a mensagem nova substitui a anterior.
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

        if (next is MedicalRecordFormSuccess) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                next.criado ? 'Prontuário criado' : 'Prontuário atualizado',
              ),
            ),
          );
          abrirProntuario();
        }
        if (next is MedicalRecordFormError) {
          messenger.showSnackBar(SnackBar(content: Text(next.message)));
        }
      },
    );

    final state = ref.watch(medicalRecordControllerProvider(patientId));
    final salvando = ref.watch(
      medicalRecordFormControllerProvider(patientId),
    ) is MedicalRecordFormSaving;
    final controller = ref.read(
      medicalRecordFormControllerProvider(patientId).notifier,
    );

    return AppScaffold(
      titulo: edicao ? 'Editar Prontuário' : 'Cadastrar Prontuário',
      rotaAtual: '/prontuario/registro',
      actions: [
        AppBackButton(
          rotaAnterior: edicao ? 'prontuario-registro' : 'prontuario',
          parametros: edicao ? parametros : const {},
        ),
      ],
      backgroundColor: AppColors.background,
      body: MedicalRecordBody(
        state: state,
        conteudo: (details) => [
          // O status só muda depois de salvar.
          MedicalRecordPatientCard(details: details),
          const SizedBox(height: 12),
          MedicalRecordForm(
            details: details,
            salvando: salvando,
            aoCriar: controller.criar,
            aoEditar: controller.atualizarProntuario,
            aoCancelar: cancelar,
            secaoInicial: secao,
            profissionais: ref.watch(evolutionProfessionalsProvider),
          ),
        ],
      ),
    );
  }
}
