import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../domain/models/appointment_history_model.dart';
import '../../domain/models/appointment_history_status.dart';

/// Card de um atendimento do histórico: data, status, paciente,
/// tipo de atendimento e profissional.
class AppointmentHistoryCard extends StatelessWidget {
  final AppointmentHistoryModel appointment;

  const AppointmentHistoryCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // Data e status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Symbols.calendar_today,
                  size: 18,
                  color: AppColors.borderAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: appointment.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '  às ${appointment.time}',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                _EtiquetaStatus(status: appointment.status),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Paciente | profissional
          Padding(
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.airline_seat_recline_normal,
                      size: 22,
                      color: AppColors.borderAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patient,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          appointment.appointmentType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 24, color: Colors.grey[300]),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        appointment.professional,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _EtiquetaStatus extends StatelessWidget {
  final AppointmentHistoryStatus status;

  const _EtiquetaStatus({required this.status});

  (Color texto, Color fundo) get _cores => switch (status) {
    AppointmentHistoryStatus.confirmed => (
      AppColors.appointmentConfirmed,
      AppColors.appointmentConfirmedBackground,
    ),
    AppointmentHistoryStatus.performed => (
      AppColors.appointmentPerformed,
      AppColors.appointmentPerformedBackground,
    ),
    AppointmentHistoryStatus.canceled => (
      AppColors.appointmentCanceled,
      AppColors.appointmentCanceledBackground,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (texto, fundo) = _cores;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
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
