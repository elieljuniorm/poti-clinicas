import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../domain/models/scheduling_appointment_model.dart';

/// Tabela da agenda: Data, Paciente (com horário), Atendimento e Status.
class SchedulingAppointmentsTable extends StatelessWidget {
  final List<SchedulingAppointmentModel> appointments;

  const SchedulingAppointmentsTable({super.key, required this.appointments});

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Symbols.check_circle;
      case AppointmentStatus.pending:
        return Symbols.circle;
      case AppointmentStatus.canceled:
        return Symbols.cancel;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed;
      case AppointmentStatus.pending:
        return AppColors.statusPending;
      case AppointmentStatus.canceled:
        return AppColors.statusCanceled;
    }
  }

  static const _estiloCabecalho = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w800,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppDecorations.card,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Cabeçalho da Tabela
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'DATA',
                      textAlign: TextAlign.center,
                      style: _estiloCabecalho,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PACIENTE',
                      textAlign: TextAlign.center,
                      style: _estiloCabecalho,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ATENDIMENTO',
                      textAlign: TextAlign.center,
                      style: _estiloCabecalho,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'STATUS',
                      textAlign: TextAlign.center,
                      style: _estiloCabecalho,
                    ),
                  ),
                ],
              ),
            ),
            if (appointments.isEmpty)
              Container(
                color: AppColors.tableRowEven,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const Text(
                  'Nenhum atendimento no período',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            // Linhas da Tabela
            ...appointments.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;

              return Container(
                color: isEven ? AppColors.tableRowEven : AppColors.tableRowOdd,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.date,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.patient,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            item.time,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.appointmentType,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        _getStatusIcon(item.status),
                        color: _getStatusColor(item.status),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
