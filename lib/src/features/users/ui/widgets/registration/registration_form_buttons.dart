import 'package:flutter/material.dart';

import '../../../../../core/ui/widgets/app_action_buttons.dart';

/// Rodapé dos formulários de usuário: salvar + cancelar no cadastro;
/// só o salvar (ex.: "EDITAR CADASTRO") quando não há [aoCancelar],
/// como na edição, que volta pela seta do topo.
class RegistrationFormButtons extends StatelessWidget {
  final VoidCallback aoSalvar;
  final VoidCallback? aoCancelar;
  final bool salvando;
  final String labelSalvar;

  const RegistrationFormButtons({
    super.key,
    required this.aoSalvar,
    this.aoCancelar,
    this.salvando = false,
    this.labelSalvar = 'Salvar',
  });

  @override
  Widget build(BuildContext context) {
    final aoCancelar = this.aoCancelar;
    if (aoCancelar == null) {
      return Center(
        child: AppSaveButton(
          label: labelSalvar,
          largura: 240,
          carregando: salvando,
          onPressed: aoSalvar,
        ),
      );
    }
    return AppSaveCancelButtons(
      salvando: salvando,
      labelSalvar: labelSalvar,
      aoSalvar: aoSalvar,
      aoCancelar: aoCancelar,
    );
  }
}
