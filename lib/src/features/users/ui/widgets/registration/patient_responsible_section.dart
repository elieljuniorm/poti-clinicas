import 'package:flutter/material.dart';

import '../../../../../core/ui/formatters/mask_input_formatter.dart';
import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../../../core/ui/widgets/app_section_divider.dart';
import '../../../domain/models/patient_responsible_model.dart';
import 'registration_contact_fields.dart';

/// Campos do responsável. Ficam com o formulário (que lê os valores ao
/// salvar); a [PatientResponsibleSection] só os exibe e valida.
class PatientResponsibleFormControllers {
  final TextEditingController nome;
  final TextEditingController email;
  final TextEditingController telefone;
  final TextEditingController nascimento;

  /// Marcado: o paciente é o seu próprio responsável e o formulário do
  /// responsável fica escondido.
  bool proprioResponsavel;

  /// Com [dados], os campos já começam preenchidos (edição). O telefone
  /// vem só com dígitos e ganha a máscara aqui.
  PatientResponsibleFormControllers([
    PatientResponsibleModel? dados,
    this.proprioResponsavel = true,
  ]) : nome = TextEditingController(text: dados?.name),
       email = TextEditingController(text: dados?.email),
       telefone = TextEditingController(
         text: MaskInputFormatter.telefone().formatar(dados?.phone ?? ''),
       ),
       nascimento = TextEditingController(text: dados?.birthDate);

  PatientResponsibleModel get dados => PatientResponsibleModel(
    name: nome.text.trim(),
    email: email.text.trim(),
    phone: telefone.text,
    birthDate: nascimento.text.trim(),
  );

  void dispose() {
    for (final controller in [nome, email, telefone, nascimento]) {
      controller.dispose();
    }
  }
}

/// Área "RESPONSÁVEL" do cadastro de paciente: pergunta se o paciente é o
/// próprio responsável e, se não for, abre os dados do responsável.
class PatientResponsibleSection extends StatefulWidget {
  final PatientResponsibleFormControllers controllers;
  final bool habilitado;

  const PatientResponsibleSection({
    super.key,
    required this.controllers,
    this.habilitado = true,
  });

  @override
  State<PatientResponsibleSection> createState() =>
      _PatientResponsibleSectionState();
}

class _PatientResponsibleSectionState extends State<PatientResponsibleSection> {
  PatientResponsibleFormControllers get _campos => widget.controllers;

  void _alternar(bool? marcado) {
    setState(() => _campos.proprioResponsavel = marcado ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.habilitado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionDivider(titulo: 'RESPONSÁVEL'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: habilitado
                ? () => _alternar(!_campos.proprioResponsavel)
                : null,
            child: Row(
              children: [
                Checkbox(
                  value: _campos.proprioResponsavel,
                  onChanged: habilitado ? _alternar : null,
                  activeColor: AppColors.borderAccent,
                  side: const BorderSide(
                    color: AppColors.borderAccent,
                    width: 1.5,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'O paciente é o seu próprio responsável',
                    style: AppTextStyles.fieldValue,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Desmarcado: os campos entram no Form e passam a ser validados.
        if (!_campos.proprioResponsavel)
          RegistrationContactFields(
            nome: _campos.nome,
            email: _campos.email,
            telefone: _campos.telefone,
            nascimento: _campos.nascimento,
            habilitado: habilitado,
            dicaEmail: 'email@gmail.com',
            nascimentoObrigatorio: true,
          ),
      ],
    );
  }
}
