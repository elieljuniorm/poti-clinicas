import '../../../../core/utils/datas.dart';
import '../../../home/domain/models/daily_appointment_model.dart';

export '../../../home/domain/models/daily_appointment_model.dart'
    show AppointmentStatus;

/// Um atendimento da agenda: uma data de um agendamento.
///
/// Ao criar um agendamento, cada data escolhida vira um atendimento
/// próprio (status [AppointmentStatus.pending]) que pode ser editado
/// sozinho: status, data, horário, profissional, tipo e caso clínico.
class SchedulingAppointmentModel {
  final String id;
  final String patientId;

  /// Nome do paciente (para a tabela, sem buscar o cadastro).
  final String patient;
  final String professionalId;
  final String professional;
  final String appointmentType;
  final String? clinicalCase;
  final DateTime start;
  final DateTime end;
  final AppointmentStatus status;

  const SchedulingAppointmentModel({
    required this.id,
    required this.patientId,
    required this.patient,
    required this.professionalId,
    required this.professional,
    required this.appointmentType,
    this.clinicalCase,
    required this.start,
    required this.end,
    required this.status,
  });

  /// "15/07" (coluna DATA da tabela).
  String get date => Datas.data(start).substring(0, 5);

  /// "14:30" (abaixo do paciente na tabela).
  String get time => Datas.hora(start.hour, start.minute);

  SchedulingAppointmentModel copyWith({
    String? professionalId,
    String? professional,
    String? appointmentType,
    String? clinicalCase,
    DateTime? start,
    DateTime? end,
    AppointmentStatus? status,
  }) {
    return SchedulingAppointmentModel(
      id: id,
      patientId: patientId,
      patient: patient,
      professionalId: professionalId ?? this.professionalId,
      professional: professional ?? this.professional,
      appointmentType: appointmentType ?? this.appointmentType,
      clinicalCase: clinicalCase ?? this.clinicalCase,
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }
}
