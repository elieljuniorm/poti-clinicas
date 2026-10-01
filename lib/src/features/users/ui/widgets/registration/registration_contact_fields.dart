import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/formatters/mask_input_formatter.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';

/// Nome, e-mail, telefone e data de nascimento: o começo dos dois
/// formulários de cadastro (profissional e paciente).
class RegistrationContactFields extends StatelessWidget {
  final TextEditingController nome;
  final TextEditingController email;
  final TextEditingController telefone;
  final TextEditingController nascimento;
  final bool habilitado;
  final String dicaEmail;
  final bool nascimentoObrigatorio;

  const RegistrationContactFields({
    super.key,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.nascimento,
    this.habilitado = true,
    this.dicaEmail = 'email@.com',
    this.nascimentoObrigatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileField(
          rotulo: 'NOME',
          icon: Symbols.person,
          controller: nome,
          habilitado: habilitado,
          dica: 'Nome Completo',
          validator: FormValidators.obrigatorio,
        ),
        ProfileField(
          rotulo: 'EMAIL',
          icon: Symbols.mail,
          controller: email,
          habilitado: habilitado,
          teclado: TextInputType.emailAddress,
          dica: dicaEmail,
          validator: FormValidators.email,
        ),
        ProfileField(
          rotulo: 'TELEFONE',
          icon: Symbols.call,
          controller: telefone,
          habilitado: habilitado,
          teclado: TextInputType.phone,
          formatadores: [MaskInputFormatter.telefone()],
          dica: '(91) 9 9999-9999',
          validator: FormValidators.telefone,
        ),
        ProfileField(
          rotulo: 'DATA DE NASCIMENTO',
          controller: nascimento,
          habilitado: habilitado,
          teclado: TextInputType.number,
          formatadores: [MaskInputFormatter.data()],
          dica: 'DD/MM/AAAA',
          validator: (valor) =>
              FormValidators.data(valor, obrigatoria: nascimentoObrigatorio),
        ),
      ],
    );
  }
}
