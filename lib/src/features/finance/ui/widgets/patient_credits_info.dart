import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../application/finance_controller.dart';

/// Aviso com os créditos de agendamento do paciente (sessões já faturadas
/// e ainda não agendadas). Não aparece enquanto carrega, em erro ou sem
/// créditos.
///
/// [mensagem] monta o texto a partir dos créditos (ex.: "serão usados
/// neste agendamento").
class PatientCreditsInfo extends ConsumerWidget {
  final String patientId;
  final String Function(int creditos) mensagem;

  const PatientCreditsInfo({
    super.key,
    required this.patientId,
    required this.mensagem,
  });

  static String creditos(int total) => total == 1
      ? '1 crédito de agendamento'
      : '$total créditos de agendamento';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditos = ref.watch(patientCreditsProvider(patientId)).value ?? 0;
    if (creditos == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.actionCardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderAccent),
        ),
        child: Row(
          children: [
            const Icon(
              Symbols.confirmation_number,
              size: 20,
              color: AppColors.borderAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensagem(creditos),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
