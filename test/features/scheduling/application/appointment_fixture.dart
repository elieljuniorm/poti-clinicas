import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_appointment_model.dart';

/// Atendimento de teste: 15/07/2030 das 14:30 às 15:30, pendente.
SchedulingAppointmentModel atendimentoDeTeste({
  String id = '1',
  String patientId = '6',
  String patient = 'Antônio Araújo',
  String professionalId = '1',
  String professional = 'Arnaldo Ribeiro',
  String appointmentType = 'Avaliação',
  String? clinicalCase,
  DateTime? start,
  DateTime? end,
  AppointmentStatus status = AppointmentStatus.pending,
}) {
  final inicio = start ?? DateTime(2030, 7, 15, 14, 30);
  return SchedulingAppointmentModel(
    id: id,
    patientId: patientId,
    patient: patient,
    professionalId: professionalId,
    professional: professional,
    appointmentType: appointmentType,
    clinicalCase: clinicalCase,
    start: inicio,
    end: end ?? inicio.add(const Duration(hours: 1)),
    status: status,
  );
}
