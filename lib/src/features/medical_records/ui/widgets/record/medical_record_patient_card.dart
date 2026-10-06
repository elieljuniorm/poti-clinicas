import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../domain/models/medical_record_details_model.dart';
import '../medical_record_status_tag.dart';

/// Card do topo das telas do prontuário: nome, e-mail e status do
/// paciente; especialidade e profissional responsável.
class MedicalRecordPatientCard extends StatelessWidget {
  final MedicalRecordDetailsModel details;

  const MedicalRecordPatientCard({super.key, required this.details});

  static const _rotulo = TextStyle(fontSize: 13, color: AppColors.textHint);
  static const _valor = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final summary = details.summary;

    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.patientName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: 'E-mail: ',
                        style: _rotulo,
                        children: [
                          TextSpan(text: details.email, style: _valor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: MedicalRecordStatusTag(status: summary.status),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.borderAccent,
                  ),
                ),
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Profissional: ',
                    style: _rotulo,
                    children: [
                      TextSpan(text: details.professionalName, style: _valor),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
