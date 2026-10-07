import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../domain/models/evolution_model.dart';

/// Etiqueta do status do paciente na evolução (mesmo visual da etiqueta
/// do prontuário).
class EvolutionStatusTag extends StatelessWidget {
  final EvolutionPatientStatus status;

  const EvolutionStatusTag({super.key, required this.status});

  (Color texto, Color fundo) get _cores => switch (status) {
    EvolutionPatientStatus.inTherapy || EvolutionPatientStatus.improving => (
      AppColors.recordInTherapy,
      AppColors.recordInTherapyBackground,
    ),
    EvolutionPatientStatus.stable => (
      AppColors.recordNew,
      AppColors.recordNewBackground,
    ),
    EvolutionPatientStatus.worsening => (
      AppColors.recordPending,
      AppColors.recordPendingBackground,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (texto, fundo) = _cores;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: texto,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
