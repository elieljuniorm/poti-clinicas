import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/discharge_model.dart';
import '../domain/models/medical_record_content.dart';
import '../domain/models/medical_record_create_model.dart';
import '../domain/models/medical_record_details_model.dart';
import '../domain/repositories/medical_records_repository.dart';
import '../ui/states/medical_record_state.dart';
import 'medical_records_controller.dart';

/// Carrega o prontuário de um paciente (um controller por id).
class MedicalRecordController extends Notifier<MedicalRecordState> {
  final String patientId;

  MedicalRecordController(this.patientId);

  MedicalRecordsRepository get _repository =>
      ref.read(medicalRecordsRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  MedicalRecordState build() {
    Future.microtask(carregar);
    return const MedicalRecordState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final details = await _repository.buscarProntuario(patientId);
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = MedicalRecordState(details: details);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar prontuário: $e',
      );
    }
  }

  /// Troca pelo prontuário que a API devolveu ao salvar (status novo).
  void atualizar(MedicalRecordDetailsModel details) {
    state = MedicalRecordState(details: details);
  }
}

/// Salva o formulário do prontuário. O status do paciente só muda aqui,
/// quando o prontuário é salvo.
class MedicalRecordFormController extends Notifier<MedicalRecordFormState> {
  final String patientId;

  MedicalRecordFormController(this.patientId);

  MedicalRecordsRepository get _repository =>
      ref.read(medicalRecordsRepositoryProvider);

  @override
  MedicalRecordFormState build() {
    return const MedicalRecordFormInitial();
  }

  Future<void> criar(MedicalRecordCreateModel prontuario) {
    return _salvar(
      criado: true,
      () => _repository.criarProntuario(patientId, prontuario),
    );
  }

  Future<void> atualizarProntuario(MedicalRecordContent anamnese) {
    return _salvar(
      criado: false,
      () => _repository.atualizarProntuario(patientId, anamnese),
    );
  }

  Future<void> _salvar(
    Future<MedicalRecordDetailsModel> Function() chamada, {
    required bool criado,
  }) async {
    if (state is MedicalRecordFormSaving) return;
    state = const MedicalRecordFormSaving();

    try {
      final details = await chamada();
      if (!ref.mounted) return;

      // A lista e a tela do prontuário já mostram o status novo.
      unawaited(ref.read(medicalRecordsControllerProvider.notifier).carregar());
      ref
          .read(medicalRecordControllerProvider(patientId).notifier)
          .atualizar(details);

      state = MedicalRecordFormSuccess(criado: criado);
    } catch (e) {
      if (!ref.mounted) return;
      state = MedicalRecordFormError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

/// Protocolo de alta: fecha o prontuário. Como salvar o prontuário, muda
/// o status do paciente (para "Alta Médica").
class DischargeController extends Notifier<DischargeState> {
  final String patientId;

  DischargeController(this.patientId);

  MedicalRecordsRepository get _repository =>
      ref.read(medicalRecordsRepositoryProvider);

  @override
  DischargeState build() {
    return const DischargeInitial();
  }

  Future<void> registrarAlta({
    required DischargeReason motivo,
    required String descricao,
  }) async {
    if (state is DischargeSaving) return;
    state = const DischargeSaving();

    try {
      final details = await _repository.registrarAlta(
        patientId,
        motivo: motivo,
        descricao: descricao,
      );
      if (!ref.mounted) return;

      // A lista e a tela do prontuário já mostram o status novo.
      unawaited(ref.read(medicalRecordsControllerProvider.notifier).carregar());
      ref
          .read(medicalRecordControllerProvider(patientId).notifier)
          .atualizar(details);

      state = const DischargeSuccess();
    } catch (e) {
      if (!ref.mounted) return;
      state = DischargeError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o prontuário é buscado de novo a cada abertura da tela.
final medicalRecordControllerProvider = NotifierProvider.autoDispose
    .family<MedicalRecordController, MedicalRecordState, String>(
      MedicalRecordController.new,
    );

final medicalRecordFormControllerProvider = NotifierProvider.autoDispose
    .family<MedicalRecordFormController, MedicalRecordFormState, String>(
      MedicalRecordFormController.new,
    );

final dischargeControllerProvider = NotifierProvider.autoDispose
    .family<DischargeController, DischargeState, String>(
      DischargeController.new,
    );
