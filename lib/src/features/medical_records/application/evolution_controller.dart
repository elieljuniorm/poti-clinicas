import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/application/users_controller.dart';
import '../../users/domain/models/user_role.dart';
import '../domain/models/evolution_model.dart';
import '../domain/repositories/medical_records_repository.dart';
import '../ui/states/medical_record_state.dart';
import 'medical_record_controller.dart';
import 'medical_records_controller.dart';

/// Registra uma nova evolução. Como salvar o prontuário, pode mudar o
/// status do paciente (ex.: sair de "Pendente").
class EvolutionFormController extends Notifier<EvolutionFormState> {
  final String patientId;

  EvolutionFormController(this.patientId);

  MedicalRecordsRepository get _repository =>
      ref.read(medicalRecordsRepositoryProvider);

  @override
  EvolutionFormState build() {
    return const EvolutionFormInitial();
  }

  Future<void> registrar(EvolutionCreateModel evolucao) async {
    if (state is EvolutionFormSaving) return;
    state = const EvolutionFormSaving();

    try {
      final details = await _repository.registrarEvolucao(patientId, evolucao);
      if (!ref.mounted) return;

      // A lista e a tela do prontuário já mostram o status novo.
      unawaited(ref.read(medicalRecordsControllerProvider.notifier).carregar());
      ref
          .read(medicalRecordControllerProvider(patientId).notifier)
          .atualizar(details);

      state = EvolutionFormSuccess(evolucao.sessionNumber);
    } catch (e) {
      if (!ref.mounted) return;
      state = EvolutionFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ============================================================
// Providers
// ============================================================

final evolutionFormControllerProvider = NotifierProvider.autoDispose
    .family<EvolutionFormController, EvolutionFormState, String>(
      EvolutionFormController.new,
    );

/// Profissionais ativos (id → nome) para o select "PROFISSIONAL" da
/// evolução, vindos da lista de usuários.
final evolutionProfessionalsProvider = Provider<Map<String, String>>((ref) {
  final usuarios = ref.watch(usersControllerProvider).users;
  return {
    for (final u in usuarios)
      if (u.role == UserRole.professional && u.active) u.id: u.name,
  };
});
