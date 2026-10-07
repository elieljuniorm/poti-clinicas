import '../../domain/models/medical_record_details_model.dart';

/// Carregamento do prontuário de um paciente.
class MedicalRecordState {
  final bool isLoading;
  final String? errorMessage;
  final MedicalRecordDetailsModel? details;

  const MedicalRecordState({
    this.isLoading = false,
    this.errorMessage,
    this.details,
  });

  MedicalRecordState copyWith({
    bool? isLoading,
    String? errorMessage,
    MedicalRecordDetailsModel? details,
  }) {
    return MedicalRecordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      details: details ?? this.details,
    );
  }
}

/// Salvamento do formulário do prontuário (criar ou editar).
sealed class MedicalRecordFormState {
  const MedicalRecordFormState();
}

class MedicalRecordFormInitial extends MedicalRecordFormState {
  const MedicalRecordFormInitial();
}

class MedicalRecordFormSaving extends MedicalRecordFormState {
  const MedicalRecordFormSaving();
}

class MedicalRecordFormSuccess extends MedicalRecordFormState {
  /// `true` quando o prontuário acabou de ser criado.
  final bool criado;
  const MedicalRecordFormSuccess({required this.criado});
}

class MedicalRecordFormError extends MedicalRecordFormState {
  final String message;
  const MedicalRecordFormError(this.message);
}

/// Registro da alta (protocolo de alta) na visualização do prontuário.
sealed class DischargeState {
  const DischargeState();
}

class DischargeInitial extends DischargeState {
  const DischargeInitial();
}

class DischargeSaving extends DischargeState {
  const DischargeSaving();
}

class DischargeSuccess extends DischargeState {
  const DischargeSuccess();
}

class DischargeError extends DischargeState {
  final String message;
  const DischargeError(this.message);
}

/// Registro de uma nova evolução (modal "Nova Evolução").
sealed class EvolutionFormState {
  const EvolutionFormState();
}

class EvolutionFormInitial extends EvolutionFormState {
  const EvolutionFormInitial();
}

class EvolutionFormSaving extends EvolutionFormState {
  const EvolutionFormSaving();
}

class EvolutionFormSuccess extends EvolutionFormState {
  final int sessionNumber;
  const EvolutionFormSuccess(this.sessionNumber);
}

class EvolutionFormError extends EvolutionFormState {
  final String message;
  const EvolutionFormError(this.message);
}
