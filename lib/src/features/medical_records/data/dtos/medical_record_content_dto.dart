import '../../domain/models/medical_record_content.dart';

/// Representa o conteúdo do prontuário exatamente como a API envia e
/// recebe: um objeto por seção, com os campos dentro. Campos vazios não
/// são enviados.
class MedicalRecordContentDto {
  static const _secoes = {
    MedicalRecordSection.anamnesis: 'anamnesis',
    MedicalRecordSection.physicalAssessment: 'physical_assessment',
    MedicalRecordSection.therapeuticPlan: 'therapeutic_plan',
  };

  static const _campos = {
    MedicalRecordField.chiefComplaint: 'chief_complaint',
    MedicalRecordField.secondaryComplaint: 'secondary_complaint',
    MedicalRecordField.medicalDiagnosis: 'medical_diagnosis',
    MedicalRecordField.diseaseHistory: 'disease_history',
    MedicalRecordField.rangeOfMotion: 'range_of_motion',
    MedicalRecordField.exams: 'exams',
    MedicalRecordField.surgeries: 'surgeries',
    MedicalRecordField.medications: 'medications',
    MedicalRecordField.familyHistory: 'family_history',
    MedicalRecordField.restrictions: 'restrictions',
    MedicalRecordField.activities: 'activities',
    MedicalRecordField.posturalAssessment: 'postural_assessment',
    MedicalRecordField.muscleStrength: 'muscle_strength',
    MedicalRecordField.scales: 'scales',
    MedicalRecordField.goals: 'goals',
    MedicalRecordField.generalNotes: 'general_notes',
  };

  /// Seção → (campo → texto), com as chaves da API.
  final Map<String, Map<String, String>> values;

  MedicalRecordContentDto(this.values);

  // JSON → DTO (chaves desconhecidas são ignoradas)
  factory MedicalRecordContentDto.fromJson(Map<String, dynamic> json) {
    return MedicalRecordContentDto({
      for (final secao in _secoes.values)
        if (json[secao] is Map)
          secao: {
            for (final MapEntry(:key, :value) in (json[secao] as Map).entries)
              if (value is String) key as String: value,
          },
    });
  }

  // Model de domínio → DTO
  factory MedicalRecordContentDto.fromDomain(MedicalRecordContent model) {
    final values = <String, Map<String, String>>{};
    for (final MapEntry(key: campo, value: chave) in _campos.entries) {
      final texto = model[campo].trim();
      if (texto.isEmpty) continue;
      values.putIfAbsent(_secoes[campo.secao]!, () => {})[chave] = texto;
    }
    return MedicalRecordContentDto(values);
  }

  Map<String, dynamic> toJson() => {
    for (final MapEntry(:key, :value) in values.entries) key: {...value},
  };

  // DTO → Model de domínio
  MedicalRecordContent toDomain() {
    return MedicalRecordContent({
      for (final MapEntry(key: campo, value: chave) in _campos.entries)
        campo: ?values[_secoes[campo.secao]]?[chave],
    });
  }
}
