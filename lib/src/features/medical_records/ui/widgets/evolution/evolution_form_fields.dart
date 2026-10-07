import 'package:flutter/material.dart';

import '../../../../../core/ui/formatters/mask_input_formatter.dart';
import '../../../../../core/ui/widgets/app_section_divider.dart';
import '../../../../../core/ui/widgets/app_select_field.dart';
import '../../../../../core/utils/datas.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../domain/models/evolution_model.dart';

/// Campos da evolução. Ficam com quem mostra o formulário (que lê os
/// valores ao salvar); a [EvolutionFormFields] só os exibe e valida.
class EvolutionFormControllers {
  final TextEditingController data;
  final descricao = TextEditingController();
  final observacoes = TextEditingController();
  final progresso = TextEditingController();
  final resultadoEscala = TextEditingController();
  String? profissionalId;
  EvolutionPatientStatus? status;
  AssessmentScale? escala;

  /// Com [dataSessao], a data já começa preenchida (ex.: a última sessão
  /// realizada, na criação do prontuário).
  EvolutionFormControllers({DateTime? dataSessao})
    : data = TextEditingController(
        text: dataSessao == null ? null : Datas.data(dataSessao),
      );

  /// "DD/MM/AAAA" → data. Só chamado depois de validar.
  DateTime get _dataSessao {
    final [dia, mes, ano] = data.text.trim().split('/').map(int.parse).toList();
    return DateTime(ano, mes, dia);
  }

  /// Evolução preenchida, com o número da sessão. Valide antes.
  EvolutionCreateModel dados(int numeroSessao) {
    final escala = this.escala;
    return EvolutionCreateModel(
      sessionNumber: numeroSessao,
      sessionDate: _dataSessao,
      professionalId: profissionalId!,
      description: descricao.text.trim(),
      observations: observacoes.text.trim(),
      clinicalProgress: progresso.text.trim(),
      patientStatus: status!,
      scale: escala == null
          ? null
          : EvolutionScaleModel(
              scale: escala,
              result: resultadoEscala.text.trim(),
            ),
    );
  }

  void dispose() {
    for (final controller in [
      data,
      descricao,
      observacoes,
      progresso,
      resultadoEscala,
    ]) {
      controller.dispose();
    }
  }
}

/// Formulário da evolução: data e número da sessão, profissional, o que
/// foi feito, observações, progresso, status do paciente e a escala de
/// avaliação (opcional). Usado no modal "Nova Evolução" e na criação do
/// prontuário.
class EvolutionFormFields extends StatefulWidget {
  final EvolutionFormControllers controllers;

  /// Número da sessão: fixo, calculado a partir da última evolução.
  final int numeroSessao;

  /// Profissionais ativos (id → nome).
  final Map<String, String> profissionais;
  final bool habilitado;

  const EvolutionFormFields({
    super.key,
    required this.controllers,
    required this.numeroSessao,
    required this.profissionais,
    this.habilitado = true,
  });

  @override
  State<EvolutionFormFields> createState() => _EvolutionFormFieldsState();
}

class _EvolutionFormFieldsState extends State<EvolutionFormFields> {
  EvolutionFormControllers get _campos => widget.controllers;

  String? _validarData(String? valor) =>
      FormValidators.data(valor, obrigatoria: true);

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.habilitado;
    final profissionais = widget.profissionais;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ProfileField(
                rotulo: 'DATA DA SESSÃO *',
                controller: _campos.data,
                habilitado: habilitado,
                teclado: TextInputType.number,
                formatadores: [MaskInputFormatter.data()],
                dica: 'DD/MM/AAAA',
                validator: _validarData,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ProfileField(
                // Key: o número muda quando outra evolução é registrada.
                key: ValueKey(widget.numeroSessao),
                rotulo: 'Nº SESSÃO',
                valorInicial: '${widget.numeroSessao}',
                habilitado: false,
              ),
            ),
          ],
        ),
        AppSelectField<String>(
          rotulo: 'PROFISSIONAL *',
          opcoes: profissionais.keys.toList(),
          rotuloOpcao: (id) => profissionais[id] ?? '',
          valor: _campos.profissionalId,
          habilitado: habilitado && profissionais.isNotEmpty,
          dica: profissionais.isEmpty
              ? 'Carregando profissionais...'
              : 'Selecione',
          aoMudar: (id) => setState(() => _campos.profissionalId = id),
          validator: FormValidators.selecao,
        ),
        ProfileField(
          rotulo: 'DESCRIÇÃO DA SESSÃO (CONDUTA REALIZADA) *',
          controller: _campos.descricao,
          habilitado: habilitado,
          multilinha: true,
          linhasMinimas: 3,
          dica: 'Técnicas e exercícios realizados na sessão',
          validator: FormValidators.obrigatorio,
        ),
        ProfileField(
          rotulo: 'OBSERVAÇÕES RELEVANTES',
          controller: _campos.observacoes,
          habilitado: habilitado,
          multilinha: true,
          dica: 'Queixas e intercorrências durante a sessão',
        ),
        ProfileField(
          rotulo: 'EVOLUÇÃO / PROGRESSO CLÍNICO',
          controller: _campos.progresso,
          habilitado: habilitado,
          multilinha: true,
          dica: 'Como o paciente evoluiu desde a última sessão',
        ),
        AppSelectField<EvolutionPatientStatus>(
          rotulo: 'STATUS DO PACIENTE *',
          opcoes: EvolutionPatientStatus.values,
          rotuloOpcao: _rotuloStatus,
          valor: _campos.status,
          habilitado: habilitado,
          aoMudar: (status) => setState(() => _campos.status = status),
          validator: FormValidators.selecao,
        ),

        // ---------- Escalas de avaliação (opcional) ----------
        const AppSectionDivider(titulo: 'ESCALAS DE AVALIAÇÃO'),
        AppSelectField<AssessmentScale?>(
          rotulo: 'ESCALA DE AVALIAÇÃO',
          opcoes: const [null, ...AssessmentScale.values],
          rotuloOpcao: _rotuloEscala,
          valor: _campos.escala,
          habilitado: habilitado,
          dica: 'Nenhuma',
          aoMudar: (escala) => setState(() => _campos.escala = escala),
        ),
        // Com uma escala escolhida, o resultado passa a ser obrigatório.
        if (_campos.escala != null)
          ProfileField(
            rotulo: 'RESULTADO DA ESCALA *',
            controller: _campos.resultadoEscala,
            habilitado: habilitado,
            dica: 'Ex.: 3/10',
            validator: FormValidators.obrigatorio,
          ),
      ],
    );
  }
}

String _rotuloStatus(EvolutionPatientStatus status) => status.label;

String _rotuloEscala(AssessmentScale? escala) => escala?.label ?? 'Nenhuma';
