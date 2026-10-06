import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../../core/ui/widgets/app_section_divider.dart';
import '../../../../../core/utils/datas.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../domain/models/medical_record_content.dart';
import '../../../domain/models/medical_record_create_model.dart';
import '../../../domain/models/medical_record_details_model.dart';

/// Formulário do prontuário: as seções (anamnese, avaliação física e
/// plano terapêutico) com os seus campos.
///
/// - Sem prontuário (cadastro): se o paciente já teve sessão, a evolução
///   dela pode ser registrada junto (marcado por padrão). Salva com
///   [aoCriar].
/// - Com prontuário (edição): campos preenchidos; salva com [aoEditar].
///   Abre rolado até a [secaoInicial] (o lápis tocado na visualização).
class MedicalRecordForm extends StatefulWidget {
  final MedicalRecordDetailsModel details;
  final bool salvando;
  final ValueChanged<MedicalRecordCreateModel> aoCriar;
  final ValueChanged<MedicalRecordContent> aoEditar;
  final VoidCallback aoCancelar;
  final MedicalRecordSection? secaoInicial;

  const MedicalRecordForm({
    super.key,
    required this.details,
    required this.aoCriar,
    required this.aoEditar,
    required this.aoCancelar,
    this.salvando = false,
    this.secaoInicial,
  });

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  final _formKey = GlobalKey<FormState>();

  late final bool _edicao = widget.details.record != null;

  late final Map<MedicalRecordField, TextEditingController> _campos = {
    for (final campo in MedicalRecordField.values)
      campo: TextEditingController(text: widget.details.record?.content[campo]),
  };
  final _evolucaoController = TextEditingController();

  /// A evolução só existe no cadastro e se houve sessão para evoluir.
  late final bool _podeEvoluir =
      !_edicao && widget.details.summary.lastSession != null;
  bool _registrarEvolucao = true;

  final _secoes = {
    for (final secao in MedicalRecordSection.values) secao: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    final secao = widget.secaoInicial;
    // A primeira seção já está no topo.
    if (secao == null || secao == MedicalRecordSection.values.first) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _secoes[secao]!.currentContext;
      if (contexto == null || !contexto.mounted) return;
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    for (final controller in _campos.values) {
      controller.dispose();
    }
    _evolucaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final conteudo = MedicalRecordContent({
      for (final MapEntry(key: campo, value: controller) in _campos.entries)
        campo: controller.text.trim(),
    });

    if (_edicao) {
      widget.aoEditar(conteudo);
      return;
    }
    widget.aoCriar(
      MedicalRecordCreateModel(
        content: conteudo,
        evolution: _podeEvoluir && _registrarEvolucao
            ? _evolucaoController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salvando = widget.salvando;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final secao in MedicalRecordSection.values) ...[
            AppSectionDivider(key: _secoes[secao], titulo: secao.label),
            // Provisório: os obrigatórios ainda serão definidos pela clínica.
            if (secao == MedicalRecordSection.values.first)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text('* Campos obrigatórios', style: _legenda),
              ),
            for (final campo in secao.campos)
              ProfileField(
                rotulo: campo.obrigatorio ? '${campo.label} *' : campo.label,
                controller: _campos[campo],
                habilitado: !salvando,
                multilinha: true,
                linhasMinimas: campo.linhas,
                dica: campo.dica,
                validator: campo.obrigatorio
                    ? FormValidators.obrigatorio
                    : null,
              ),
          ],

          if (_podeEvoluir) _buildEvolucao(salvando),

          const SizedBox(height: 8),
          AppSaveCancelButtons(
            salvando: salvando,
            aoSalvar: _salvar,
            aoCancelar: widget.aoCancelar,
          ),
        ],
      ),
    );
  }

  /// "EVOLUÇÃO": registra junto a evolução da última sessão realizada.
  Widget _buildEvolucao(bool salvando) {
    final details = widget.details;
    final sessao = details.summary.lastSession!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionDivider(titulo: 'EVOLUÇÃO'),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: salvando
              ? null
              : () => setState(() => _registrarEvolucao = !_registrarEvolucao),
          child: Row(
            children: [
              Checkbox(
                value: _registrarEvolucao,
                onChanged: salvando
                    ? null
                    : (marcado) =>
                          setState(() => _registrarEvolucao = marcado ?? false),
                activeColor: AppColors.borderAccent,
                side: const BorderSide(
                  color: AppColors.borderAccent,
                  width: 1.5,
                ),
              ),
              const Expanded(
                child: Text(
                  'Registrar a evolução da sessão junto',
                  style: AppTextStyles.fieldValue,
                ),
              ),
            ],
          ),
        ),
        // Desmarcado: o campo sai do Form e não é validado.
        if (_registrarEvolucao) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'Sessão #${details.sessionCount} - ${Datas.data(sessao)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.borderAccent,
              ),
            ),
          ),
          ProfileField(
            rotulo: 'EVOLUÇÃO DA SESSÃO *',
            controller: _evolucaoController,
            habilitado: !salvando,
            multilinha: true,
            dica: 'Como o paciente evoluiu e o que foi realizado na sessão',
            validator: FormValidators.obrigatorio,
          ),
        ] else
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              'A evolução pode ser registrada depois. Passadas 24h da sessão '
              'sem evolução, o paciente fica pendente.',
              style: _legenda,
            ),
          ),
      ],
    );
  }
}

const _legenda = TextStyle(fontSize: 12, color: AppColors.textHint);
