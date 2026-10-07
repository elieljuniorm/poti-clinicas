/// Como o paciente está na sessão, segundo o profissional. É o registro
/// clínico da evolução: não muda o status do prontuário (Novo, Pendente,
/// Em Terapia, Alta Médica), que é calculado.
enum EvolutionPatientStatus {
  inTherapy('Em Terapia'),
  improving('Em Melhora'),
  stable('Estável'),
  worsening('Em Piora');

  final String label;

  const EvolutionPatientStatus(this.label);
}

/// Escalas de avaliação aplicadas na sessão.
enum AssessmentScale {
  eva('EVA - Escala Visual Analógica da dor'),
  oswestry('Oswestry - incapacidade lombar'),
  borg('Borg - esforço percebido'),
  berg('Berg - equilíbrio'),
  lysholm('Lysholm - função do joelho'),
  other('Outra escala');

  final String label;

  const AssessmentScale(this.label);
}

/// Escala aplicada e o resultado obtido (ex.: EVA 3/10).
class EvolutionScaleModel {
  final AssessmentScale scale;
  final String result;

  const EvolutionScaleModel({required this.scale, required this.result});
}

/// Evolução: o registro de uma sessão realizada no prontuário.
class EvolutionModel {
  final int sessionNumber;
  final DateTime sessionDate;

  /// Profissional que realizou a sessão.
  final String professionalName;

  /// Descrição da sessão (conduta realizada).
  final String description;
  final String observations;

  /// Evolução / progresso clínico.
  final String clinicalProgress;
  final EvolutionPatientStatus? patientStatus;
  final EvolutionScaleModel? scale;

  /// Quem registrou a evolução no sistema e quando.
  final String registeredBy;
  final DateTime registeredAt;

  const EvolutionModel({
    required this.sessionNumber,
    required this.sessionDate,
    required this.professionalName,
    required this.description,
    this.observations = '',
    this.clinicalProgress = '',
    this.patientStatus,
    this.scale,
    required this.registeredBy,
    required this.registeredAt,
  });
}

/// Nova evolução, preenchida no modal "Nova Evolução" ou junto com a
/// criação do prontuário.
class EvolutionCreateModel {
  final int sessionNumber;
  final DateTime sessionDate;
  final String professionalId;
  final String description;
  final String observations;
  final String clinicalProgress;
  final EvolutionPatientStatus patientStatus;
  final EvolutionScaleModel? scale;

  const EvolutionCreateModel({
    required this.sessionNumber,
    required this.sessionDate,
    required this.professionalId,
    required this.description,
    this.observations = '',
    this.clinicalProgress = '',
    required this.patientStatus,
    this.scale,
  });
}
