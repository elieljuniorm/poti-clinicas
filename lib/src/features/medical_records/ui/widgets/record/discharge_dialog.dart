import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../../../core/ui/widgets/app_select_field.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../domain/models/discharge_model.dart';

/// Protocolo de alta: alerta que o prontuário de [paciente] será fechado
/// e pede o motivo. Devolve o motivo escolhido e o relato, ou `null` se
/// a alta foi cancelada.
Future<({DischargeReason motivo, String descricao})?> showDischargeDialog(
  BuildContext context, {
  required String paciente,
}) {
  return showDialog(
    context: context,
    builder: (_) => _DischargeDialog(paciente: paciente),
  );
}

class _DischargeDialog extends StatefulWidget {
  final String paciente;

  const _DischargeDialog({required this.paciente});

  @override
  State<_DischargeDialog> createState() => _DischargeDialogState();
}

class _DischargeDialogState extends State<_DischargeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  DischargeReason? _motivo;

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (
      motivo: _motivo!,
      descricao: _descricaoController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Dialog (e não AlertDialog): o AlertDialog mede o conteúdo pelas
    // dimensões intrínsecas, o que a lista aberta do select não suporta.
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Symbols.warning,
              size: 36,
              color: AppColors.userDeactivate,
            ),
            const SizedBox(height: 12),
            const Text(
              'Registrar alta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'O prontuário de ${widget.paciente} será fechado: '
                        'fica só para leitura e não recebe novas evoluções. '
                        'Esta ação não pode ser desfeita.',
                        style: AppTextStyles.pageDescription,
                      ),
                      const SizedBox(height: 16),
                      AppSelectField<DischargeReason>(
                        rotulo: 'MOTIVO DA ALTA *',
                        opcoes: DischargeReason.values,
                        rotuloOpcao: _rotuloMotivo,
                        valor: _motivo,
                        aoMudar: (motivo) => setState(() => _motivo = motivo),
                        validator: FormValidators.selecao,
                      ),
                      ProfileField(
                        rotulo: 'DESCRIÇÃO *',
                        controller: _descricaoController,
                        multilinha: true,
                        linhasMinimas: 3,
                        dica:
                            'Relate o motivo e as condições do paciente '
                            'na alta',
                        validator: FormValidators.obrigatorio,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: _confirmar,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.userDeactivate,
                  ),
                  child: const Text('Confirmar alta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _rotuloMotivo(DischargeReason motivo) => motivo.label;
