import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/new_appointment_model.dart';
import '../domain/repositories/scheduling_repository.dart';
import '../ui/states/new_appointment_state.dart';
import 'scheduling_controller.dart';

/// Envia o novo agendamento (tela "Novo Atendimento" da Agenda).
class NewAppointmentController extends Notifier<NewAppointmentState> {
  SchedulingRepository get _repository =>
      ref.read(schedulingRepositoryProvider);

  @override
  NewAppointmentState build() {
    return const NewAppointmentInitial();
  }

  Future<void> agendar(NewAppointmentModel agendamento) async {
    state = const NewAppointmentSaving();

    try {
      await _repository.agendar(agendamento);
      if (!ref.mounted) return;

      // A Agenda já mostra os dados novos quando a tela voltar.
      unawaited(ref.read(schedulingControllerProvider.notifier).carregar());

      state = NewAppointmentSuccess(agendamento.sessions.length);
    } catch (e) {
      if (!ref.mounted) return;
      state = NewAppointmentError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o estado volta a [NewAppointmentInitial] sempre que
/// a tela é fechada e aberta de novo.
final newAppointmentControllerProvider =
    NotifierProvider.autoDispose<NewAppointmentController, NewAppointmentState>(
      NewAppointmentController.new,
    );
