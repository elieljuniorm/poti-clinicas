import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../domain/models/medical_record_status.dart';

/// Etiqueta do status do paciente (Em Terapia, Novo, Pendente, Alta Médica).
class MedicalRecordStatusTag extends StatelessWidget {
  final MedicalRecordStatus status;

  const MedicalRecordStatusTag({super.key, required this.status});

  (Color texto, Color fundo) get _cores => switch (status) {
    MedicalRecordStatus.inTherapy => (
      AppColors.recordInTherapy,
      AppColors.recordInTherapyBackground,
    ),
    MedicalRecordStatus.newPatient => (
      AppColors.recordNew,
      AppColors.recordNewBackground,
    ),
    MedicalRecordStatus.pending => (
      AppColors.recordPending,
      AppColors.recordPendingBackground,
    ),
    MedicalRecordStatus.discharged => (
      AppColors.recordDischarged,
      AppColors.recordDischargedBackground,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (texto, fundo) = _cores;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: texto,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
