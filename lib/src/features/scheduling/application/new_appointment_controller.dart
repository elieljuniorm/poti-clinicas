import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../finance/application/finance_controller.dart';
import '../../finance/domain/models/appointment_billing_model.dart';
import '../domain/models/new_appointment_model.dart';
import '../domain/repositories/scheduling_repository.dart';
import '../ui/states/new_appointment_state.dart';
import 'scheduling_controller.dart';

/// Envia o novo agendamento (tela "Novo Atendimento" da Agenda) e fatura
/// as sessões no Financeiro: usa os créditos de agendamento do paciente e
/// manda o restante para a pré-fatura.
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
    } catch (e) {
      if (!ref.mounted) return;
      state = NewAppointmentError(e.toString().replaceFirst('Exception: ', ''));
      return;
    }

    // A Agenda já mostra os dados novos quando a tela voltar.
    unawaited(ref.read(schedulingControllerProvider.notifier).carregar());

    // As sessões já estão agendadas: uma falha aqui não desfaz o
    // agendamento, só avisa que a pré-fatura ficou pendente.
    final sessoes = agendamento.sessions.length;
    try {
      final faturamento = await ref
          .read(financeRepositoryProvider)
          .vincularAtendimento(
            AppointmentBillingModel(
              patientId: agendamento.patientId,
              patientName: agendamento.patientName,
              professionalId: agendamento.professionalId,
              professionalName: agendamento.professionalName,
              sessions: sessoes,
            ),
          );
      if (!ref.mounted) return;

      atualizarFinanceiro(ref);
      state = NewAppointmentSuccess(sessoes, billing: faturamento);
    } catch (e) {
      if (!ref.mounted) return;
      state = NewAppointmentSuccess(
        sessoes,
        billingError: e.toString().replaceFirst('Exception: ', ''),
      );
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
