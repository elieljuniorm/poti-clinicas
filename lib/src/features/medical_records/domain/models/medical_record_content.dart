/// Seções do prontuário, na ordem do formulário e da visualização.
enum MedicalRecordSection {
  anamnesis('ANAMNESE'),
  physicalAssessment('AVALIAÇÃO FÍSICA'),
  therapeuticPlan('PLANO TERAPÊUTICO');

  final String label;

  const MedicalRecordSection(this.label);

  /// Campos da seção, na ordem de [MedicalRecordField].
  List<MedicalRecordField> get campos =>
      MedicalRecordField.values.where((c) => c.secao == this).toList();
}

/// Campos de texto do prontuário. Para incluir um campo novo, basta
/// acrescentá-lo aqui (e a chave da API no `MedicalRecordContentDto`).
enum MedicalRecordField {
  // ---------- Anamnese ----------
  // Obrigatórios provisórios: os principais, até a clínica definir a lista.
  chiefComplaint(
    MedicalRecordSection.anamnesis,
    'QUEIXA PRINCIPAL',
    'O que levou o paciente a buscar atendimento',
    obrigatorio: true,
  ),
  secondaryComplaint(
    MedicalRecordSection.anamnesis,
    'QUEIXA SECUNDÁRIA',
    'Outras queixas relatadas',
  ),
  medicalDiagnosis(
    MedicalRecordSection.anamnesis,
    'DIAGNÓSTICO MÉDICO',
    'Diagnóstico informado pelo médico',
    obrigatorio: true,
  ),
  diseaseHistory(
    MedicalRecordSection.anamnesis,
    'HISTÓRICO PROGRESSIVO DE DOENÇAS',
    'Doenças e tratamentos anteriores',
  ),
  rangeOfMotion(
    MedicalRecordSection.anamnesis,
    'AMPLITUDE DE MOVIMENTO',
    'Medidas de flexão, extensão e testes realizados',
  ),
  exams(
    MedicalRecordSection.anamnesis,
    'EXAMES',
    'Exames de imagem e laboratoriais, com as datas',
  ),
  surgeries(
    MedicalRecordSection.anamnesis,
    'CIRURGIAS',
    'Cirurgias realizadas, com o ano',
  ),
  medications(
    MedicalRecordSection.anamnesis,
    'MEDICAMENTOS EM USO',
    'Medicamento, dose e frequência',
  ),
  familyHistory(
    MedicalRecordSection.anamnesis,
    'HISTÓRICO FAMILIAR',
    'Doenças relevantes na família',
  ),
  restrictions(
    MedicalRecordSection.anamnesis,
    'RESTRIÇÕES',
    'Movimentos e atividades a evitar',
  ),

  // ---------- Avaliação física ----------
  activities(
    MedicalRecordSection.physicalAssessment,
    'ATIVIDADES',
    'Atividades físicas e rotina de trabalho',
    linhas: 4,
  ),
  posturalAssessment(
    MedicalRecordSection.physicalAssessment,
    'AVALIAÇÃO POSTURAL',
    'Alterações posturais observadas',
  ),
  muscleStrength(
    MedicalRecordSection.physicalAssessment,
    'FORÇA MUSCULAR',
    'Grau de força por grupo muscular',
  ),

  // ---------- Plano terapêutico ----------
  scales(
    MedicalRecordSection.therapeuticPlan,
    'ESCALAS',
    'Escalas e questionários aplicados',
    linhas: 4,
  ),
  goals(
    MedicalRecordSection.therapeuticPlan,
    'OBJETIVOS',
    'Objetivos e prazo do tratamento',
    linhas: 4,
  ),
  generalNotes(
    MedicalRecordSection.therapeuticPlan,
    'OBS GERAIS',
    'Observações sobre o paciente e o tratamento',
    linhas: 4,
  );

  final MedicalRecordSection secao;
  final String label;
  final String dica;
  final bool obrigatorio;

  /// Linhas visíveis do campo vazio no formulário (ele cresce com o texto).
  final int linhas;

  const MedicalRecordField(
    this.secao,
    this.label,
    this.dica, {
    this.obrigatorio = false,
    this.linhas = 2,
  });
}

/// Conteúdo do prontuário: o texto de cada [MedicalRecordField].
class MedicalRecordContent {
  final Map<MedicalRecordField, String> _valores;

  const MedicalRecordContent([
    Map<MedicalRecordField, String> valores = const {},
  ]) : _valores = valores;

  /// Texto do [campo]; vazio quando não foi preenchido.
  String operator [](MedicalRecordField campo) => _valores[campo] ?? '';
}
