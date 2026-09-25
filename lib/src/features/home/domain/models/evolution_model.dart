enum EvolutionStatus { open, closed }

class EvolutionModel {
  final String date;
  final String time;
  final String professional;
  final String patient;
  final String appointmentType;
  final EvolutionStatus status;

  const EvolutionModel({
    required this.date,
    required this.time,
    required this.professional,
    required this.patient,
    required this.appointmentType,
    required this.status,
  });
}
