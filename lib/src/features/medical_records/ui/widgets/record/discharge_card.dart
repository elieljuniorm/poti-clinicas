import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/utils/datas.dart';
import '../../../domain/models/discharge_model.dart';

/// Alta registrada: data, profissional, motivo e o relato.
class DischargeCard extends StatelessWidget {
  final DischargeModel discharge;

  const DischargeCard({super.key, required this.discharge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alta - ${Datas.data(discharge.date)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.recordDischargedBackground,
                  ),
                ),
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Profissional: ',
                    style: const TextStyle(color: AppColors.textHint),
                    children: [TextSpan(text: discharge.professionalName)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: Colors.grey[200]),
          const Text(
            'MOTIVO',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.borderAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            discharge.reason.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            discharge.description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
