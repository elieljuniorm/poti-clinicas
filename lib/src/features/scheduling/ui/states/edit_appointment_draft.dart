import 'package:flutter/material.dart';

import '../../../../core/utils/datas.dart';
import '../../domain/models/scheduling_appointment_model.dart';
import 'new_appointment_draft.dart';

/// Rascunho da edição de um atendimento. Imutável: cada ação devolve um
/// rascunho novo; o [original] só muda ao salvar.
class EditAppointmentDraft {
  final SchedulingAppointmentModel original;
  final AppointmentStatus status;

  /// Data e horários (mesmas regras do novo agendamento).
  final SessionDraft sessao;
  final String professionalId;
  final String appointmentType;

  const EditAppointmentDraft._({
    required this.original,
    required this.status,
    required this.sessao,
    required this.professionalId,
    required this.appointmentType,
  });

  factory EditAppointmentDraft.de(SchedulingAppointmentModel atendimento) {
    return EditAppointmentDraft._(
      original: atendimento,
      status: atendimento.status,
      sessao: SessionDraft(
        date: Datas.dia(atendimento.start),
        start: TimeOfDay.fromDateTime(atendimento.start),
        end: TimeOfDay.fromDateTime(atendimento.end),
      ),
      professionalId: atendimento.professionalId,
      appointmentType: atendimento.appointmentType,
    );
  }

  EditAppointmentDraft _com({
    AppointmentStatus? status,
    SessionDraft? sessao,
    String? professionalId,
    String? appointmentType,
  }) {
    return EditAppointmentDraft._(
      original: original,
      status: status ?? this.status,
      sessao: sessao ?? this.sessao,
      professionalId: professionalId ?? this.professionalId,
      appointmentType: appointmentType ?? this.appointmentType,
    );
  }

  EditAppointmentDraft alterarStatus(AppointmentStatus valor) =>
      _com(status: valor);

  /// Muda o dia e mantém os horários.
  EditAppointmentDraft alterarData(DateTime data) => _com(
    sessao: SessionDraft(
      date: Datas.dia(data),
      start: sessao.start,
      end: sessao.end,
    ),
  );

  EditAppointmentDraft definirInicio(TimeOfDay inicio) =>
      _com(sessao: sessao.copyWith(start: inicio));

  EditAppointmentDraft definirFim(TimeOfDay fim) =>
      _com(sessao: sessao.copyWith(end: fim));

  EditAppointmentDraft alterarProfissional(String id) =>
      _com(professionalId: id);

  EditAppointmentDraft alterarTipo(String tipo) => _com(appointmentType: tipo);

  bool get valido => sessao.horarioValido;

  /// Atendimento com as alterações. [professionalName]: nome do
  /// profissional escolhido; [clinicalCase]: texto do campo.
  SchedulingAppointmentModel aplicar({
    required String professionalName,
    required String clinicalCase,
  }) {
    final atendimento = sessao.toModel();
    final caso = clinicalCase.trim();
    return SchedulingAppointmentModel(
      id: original.id,
      patientId: original.patientId,
      patient: original.patient,
      professionalId: professionalId,
      professional: professionalName,
      appointmentType: appointmentType,
      clinicalCase: caso.isEmpty ? null : caso,
      start: atendimento.start,
      end: atendimento.end,
      status: status,
    );
  }

  /// Algo mudou em relação ao [original] (com o texto do caso clínico)?
  bool alterado(String clinicalCase) {
    final caso = clinicalCase.trim();
    final casoOriginal = original.clinicalCase?.trim() ?? '';
    return status != original.status ||
        professionalId != original.professionalId ||
        appointmentType != original.appointmentType ||
        caso != casoOriginal ||
        !sessao.preenchida ||
        sessao.toModel().start != original.start ||
        sessao.toModel().end != original.end;
  }
}
