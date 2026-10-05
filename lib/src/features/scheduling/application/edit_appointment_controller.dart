import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/scheduling_appointment_model.dart';
import '../domain/repositories/scheduling_repository.dart';
import '../ui/states/edit_appointment_state.dart';
import 'scheduling_controller.dart';

/// Salva a edição de um atendimento (modal "Editar agendamento").
class EditAppointmentController extends Notifier<EditAppointmentState> {
  SchedulingRepository get _repository =>
      ref.read(schedulingRepositoryProvider);

  @override
  EditAppointmentState build() {
    return const EditAppointmentInitial();
  }

  Future<void> salvar(SchedulingAppointmentModel atendimento) async {
    state = const EditAppointmentSaving();

    try {
      final salvo = await _repository.atualizarAtendimento(atendimento);
      if (!ref.mounted) return;

      // A tabela da Agenda mostra a alteração.
      unawaited(ref.read(schedulingControllerProvider.notifier).carregar());

      state = EditAppointmentSuccess(salvo);
    } catch (e) {
      if (!ref.mounted) return;
      state = EditAppointmentError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o estado volta a [EditAppointmentInitial] a cada
/// abertura do modal.
final editAppointmentControllerProvider =
    NotifierProvider.autoDispose<
      EditAppointmentController,
      EditAppointmentState
    >(EditAppointmentController.new);
