import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../application/evolution_controller.dart';
import '../../states/medical_record_state.dart';
import 'evolution_form_fields.dart';

/// Abre o modal "Nova Evolução" do paciente (padrão de
/// [showAppModalSheet]). Fechar sem salvar descarta tudo.
Future<void> showNewEvolutionModal(
  BuildContext context, {
  required String patientId,
  required int numeroSessao,
}) {
  return showAppModalSheet<void>(
    context,
    builder: (_) =>
        NewEvolutionModal(patientId: patientId, numeroSessao: numeroSessao),
  );
}

class NewEvolutionModal extends ConsumerStatefulWidget {
  final String patientId;
  final int numeroSessao;

  const NewEvolutionModal({
    super.key,
    required this.patientId,
    required this.numeroSessao,
  });

  @override
  ConsumerState<NewEvolutionModal> createState() => _NewEvolutionModalState();
}

class _NewEvolutionModalState extends ConsumerState<NewEvolutionModal> {
  final _formKey = GlobalKey<FormState>();
  final _campos = EvolutionFormControllers();

  @override
  void dispose() {
    _campos.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(evolutionFormControllerProvider(widget.patientId).notifier)
        .registrar(_campos.dados(widget.numeroSessao));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EvolutionFormState>(
      evolutionFormControllerProvider(widget.patientId),
      (previous, next) {
        if (next is EvolutionFormSuccess) {
          // O messenger é lido antes de fechar: depois do pop o contexto
          // do modal deixa de existir.
          final messenger = ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar();
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Evolução da sessão #${next.sessionNumber} salva'),
            ),
          );
        }
      },
    );

    final estado = ref.watch(evolutionFormControllerProvider(widget.patientId));
    final salvando = estado is EvolutionFormSaving;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Área fixa (não rola): arrastar aqui fecha o modal.
        const AppSheetHandle(),
        Flexible(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PREENCHA OS DADOS PARA CRIAR A NOVA EVOLUÇÃO',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageDescription,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, top: 8, bottom: 12),
                    child: Text(
                      '* Campos obrigatórios',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ),
                  EvolutionFormFields(
                    controllers: _campos,
                    numeroSessao: widget.numeroSessao,
                    profissionais: ref.watch(evolutionProfessionalsProvider),
                    habilitado: !salvando,
                  ),

                  if (estado is EvolutionFormError) ...[
                    const SizedBox(height: 8),
                    Text(
                      estado.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: AppSaveButton(
                      label: 'Salvar evolução',
                      largura: 240,
                      carregando: salvando,
                      onPressed: _salvar,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: salvando
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text(
                        'Descartar evolução',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
