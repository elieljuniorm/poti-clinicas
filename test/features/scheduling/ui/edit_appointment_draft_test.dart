import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/states/edit_appointment_draft.dart';

import '../application/appointment_fixture.dart';

void main() {
  final original = atendimentoDeTeste(clinicalCase: 'Dor lombar');

  test('começa igual ao atendimento e sem alterações', () {
    final r = EditAppointmentDraft.de(original);

    expect(r.status, AppointmentStatus.pending);
    expect(r.sessao.date, DateTime(2030, 7, 15));
    expect(r.sessao.start, const TimeOfDay(hour: 14, minute: 30));
    expect(r.sessao.end, const TimeOfDay(hour: 15, minute: 30));
    expect(r.alterado('Dor lombar'), isFalse);
  });

  test('trocar a data mantém o horário', () {
    final r = EditAppointmentDraft.de(original)
        .alterarData(DateTime(2030, 7, 20, 9, 45));

    final model = r.aplicar(
      professionalName: 'Arnaldo Ribeiro',
      clinicalCase: 'Dor lombar',
    );
    expect(model.start, DateTime(2030, 7, 20, 14, 30));
    expect(model.end, DateTime(2030, 7, 20, 15, 30));
    expect(r.alterado('Dor lombar'), isTrue);
  });

  test('aplica status, horário, profissional, tipo e caso clínico', () {
    final model = EditAppointmentDraft.de(original)
        .alterarStatus(AppointmentStatus.confirmed)
        .definirInicio(const TimeOfDay(hour: 8, minute: 0))
        .definirFim(const TimeOfDay(hour: 9, minute: 15))
        .alterarProfissional('3')
        .alterarTipo('Pediatria')
        .aplicar(
          professionalName: 'Beatriz Nogueira',
          clinicalCase: '  Reabilitação  ',
        );

    expect(model.id, original.id);
    expect(model.patientId, original.patientId);
    expect(model.status, AppointmentStatus.confirmed);
    expect(model.start, DateTime(2030, 7, 15, 8));
    expect(model.end, DateTime(2030, 7, 15, 9, 15));
    expect(model.professionalId, '3');
    expect(model.professional, 'Beatriz Nogueira');
    expect(model.appointmentType, 'Pediatria');
    expect(model.clinicalCase, 'Reabilitação');
  });

  test('caso clínico apagado vira nulo', () {
    final model = EditAppointmentDraft.de(original)
        .aplicar(professionalName: 'Arnaldo Ribeiro', clinicalCase: '   ');

    expect(model.clinicalCase, isNull);
  });

  test('fim antes do início deixa inválido', () {
    final r = EditAppointmentDraft.de(original)
        .definirFim(const TimeOfDay(hour: 14, minute: 0));

    expect(r.valido, isFalse);
  });

  test('o original não muda até salvar', () {
    EditAppointmentDraft.de(original).alterarStatus(AppointmentStatus.canceled);

    expect(original.status, AppointmentStatus.pending);
  });
}
