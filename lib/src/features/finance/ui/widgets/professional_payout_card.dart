import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../../../core/ui/widgets/app_avatar.dart';
import '../../../../core/utils/moeda.dart';
import '../../domain/models/professional_payout_model.dart';

/// Card do repasse de um profissional: foto (ou iniciais), especialidade,
/// atendimentos, valor da semana e total a pagar.
class ProfessionalPayoutCard extends StatelessWidget {
  final ProfessionalPayoutModel payout;

  const ProfessionalPayoutCard({super.key, required this.payout});

  @override
  Widget build(BuildContext context) {
    final atendimentos = payout.appointments == 1
        ? '1 atendimento'
        : '${payout.appointments} atendimentos';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          AppAvatar(fotoUrl: payout.photoUrl, nome: payout.name, raio: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payout.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Linhas de apoio quebram em vez de cortar: o valor da
                // semana nunca aparece truncado.
                Text(
                  '${payout.specialty} - $atendimentos',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Esta Semana: ${Moeda.formatar(payout.weekAmount)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.borderAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'A PAGAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Moeda.formatar(payout.amountToPay),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
