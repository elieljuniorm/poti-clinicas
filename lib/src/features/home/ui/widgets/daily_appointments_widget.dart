import 'package:flutter/material.dart';
import '../../domain/models/daily_appointment_model.dart';

class DailyAppointmentsWidget extends StatelessWidget {
  final List<DailyAppointmentModel> appointments;

  const DailyAppointmentsWidget({super.key, required this.appointments});

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed: return Icons.check_circle_outline;
      case AppointmentStatus.pending: return Icons.access_time;
      case AppointmentStatus.canceled: return Icons.cancel_outlined;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed: return Colors.green;
      case AppointmentStatus.pending: return Colors.orange;
      case AppointmentStatus.canceled: return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco para destacar do cinza
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho da Tabela (Azul Escuro)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F4C5C), // Cor escura do topo
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PACIENTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('ATENDIMENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          // Linhas da Tabela
          ...appointments.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEven = index % 2 == 0;

            return Container(
              // Linhas pares brancas, ímpares cinza clarinho
              color: isEven ? Colors.white : const Color(0xFFF9F9F9),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.patient, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                        Text(item.time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(item.appointmentType, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status), size: 20),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}