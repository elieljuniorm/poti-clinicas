import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/ui/states/new_appointment_draft.dart';
import 'package:poti_5f/src/features/users/domain/models/user_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';

void main() {
  final d15 = DateTime(2030, 7, 15);
  final d17 = DateTime(2030, 7, 17);
  final d22 = DateTime(2030, 7, 22);
  const t1430 = TimeOfDay(hour: 14, minute: 30);
  const t1530 = TimeOfDay(hour: 15, minute: 30);

  const paciente = UserModel(
    id: '2',
    name: 'Jorge Silva',
    email: 'jorge@gmail.com',
    phone: '(91) 9 9999-8888',
    role: UserRole.patient,
  );

  group('paciente', () {
    test('seleciona, troca e remove', () {
      var r = const NewAppointmentDraft().selecionarPaciente(paciente);
      expect(r.patient?.name, 'Jorge Silva');

      r = r.removerPaciente();
      expect(r.patient, isNull);
    });
  });

  group('datas', () {
    test('marca até o número de sessões e desmarca ao tocar de novo', () {
      var r = const NewAppointmentDraft().definirQuantidade(2);

      r = r.alternarData(d17).alternarData(d15);
      expect(r.sessions.map((s) => s.date), [d15, d17]); // em ordem
      expect(r.datasCompletas, isTrue);

      // Cheio: a terceira data não entra.
      expect(r.alternarData(d22).sessions, hasLength(2));

      r = r.alternarData(d15);
      expect(r.sessions.map((s) => s.date), [d17]);
      expect(r.faltamDatas, 1);
    });

    test('ignora o horário da data recebida (compara só o dia)', () {
      final r = const NewAppointmentDraft()
          .alternarData(DateTime(2030, 7, 15, 10, 30))
          .alternarData(d15);

      expect(r.sessions, isEmpty);
    });

    test('diminuir as sessões tira as datas mais distantes', () {
      final r = const NewAppointmentDraft()
          .definirQuantidade(3)
          .alternarData(d22)
          .alternarData(d15)
          .alternarData(d17)
          .definirQuantidade(2);

      expect(r.sessionCount, 2);
      expect(r.sessions.map((s) => s.date), [d15, d17]);
    });

    test('quantidade fica entre 1 e o máximo', () {
      const r = NewAppointmentDraft();
      expect(r.definirQuantidade(0).sessionCount, 1);
      expect(
        r.definirQuantidade(999).sessionCount,
        NewAppointmentDraft.maximoSessoes,
      );
    });
  });

  group('horários', () {
    test('início e fim são escolhidos à mão; nada é preenchido sozinho', () {
      var r = const NewAppointmentDraft()
          .alternarData(d15)
          .definirInicio(d15, t1430);

      expect(r.sessions.single.start, t1430);
      expect(r.sessions.single.end, isNull);
      expect(r.sessoesValidas, isFalse);

      r = r.definirFim(d15, t1530);
      expect(r.sessions.single.end, t1530);
      expect(r.sessoesValidas, isTrue);
    });

    test('cada data tem o seu horário: editar uma não muda as outras', () {
      const t0800 = TimeOfDay(hour: 8, minute: 0);
      const t0930 = TimeOfDay(hour: 9, minute: 30);
      final r = const NewAppointmentDraft()
          .definirQuantidade(3)
          .alternarData(d15)
          .alternarData(d17)
          .alternarData(d22)
          .definirInicio(d15, t1430)
          .definirFim(d15, t1530)
          .definirInicio(d17, t0800)
          .definirFim(d17, t0930);

      expect(r.sessions.map((s) => (s.start, s.end)).toList(), [
        (t1430, t1530),
        (t0800, t0930),
        (null, null),
      ]);
    });

    test('data nova começa sem horário, mesmo com outras preenchidas', () {
      final r = const NewAppointmentDraft()
          .definirQuantidade(2)
          .alternarData(d15)
          .definirInicio(d15, t1430)
          .definirFim(d15, t1530)
          .alternarData(d17);

      expect(r.sessions.last.start, isNull);
      expect(r.sessions.last.end, isNull);
    });

    test('mudar o início não mexe no fim já escolhido', () {
      final r = const NewAppointmentDraft()
          .alternarData(d15)
          .definirInicio(d15, t1430)
          .definirFim(d15, t1530)
          .definirInicio(d15, const TimeOfDay(hour: 16, minute: 0));

      expect(r.sessions.single.end, t1530);
      expect(r.sessoesValidas, isFalse); // agora o fim é antes do início
    });

    test('fim antes do início deixa a sessão inválida, com mensagem', () {
      final r = const NewAppointmentDraft()
          .alternarData(d15)
          .definirInicio(d15, t1530)
          .definirFim(d15, t1430);

      expect(r.sessoesValidas, isFalse);
      expect(
        r.sessions.single.erro(exigirPreenchimento: false),
        'O fim deve ser depois do início',
      );
    });

    test('vazio só vira erro depois de tentar salvar', () {
      final sessao = const NewAppointmentDraft()
          .alternarData(d15)
          .sessions
          .single;

      expect(sessao.erro(exigirPreenchimento: false), isNull);
      expect(sessao.erro(exigirPreenchimento: true), 'Preencha início e fim');
    });

    test('posição do seletor de fim: 1h depois, sem passar de 23:55', () {
      expect(NewAppointmentDraft.sugestaoDeFim(t1430), t1530);
      expect(
        NewAppointmentDraft.sugestaoDeFim(
          const TimeOfDay(hour: 23, minute: 30),
        ),
        const TimeOfDay(hour: 23, minute: 55),
      );
    });
  });

  test('toModel junta data e horário de cada sessão', () {
    final model = const NewAppointmentDraft()
        .selecionarPaciente(paciente)
        .alternarData(d15)
        .definirInicio(d15, t1430)
        .definirFim(d15, t1530)
        .toModel(
          professionalId: '1',
          professionalName: 'Dr. Arnaldo Ribeiro',
          appointmentType: 'Avaliação',
        );

    expect(model.patientId, '2');
    expect(model.patientName, 'Jorge Silva');
    expect(model.professionalName, 'Dr. Arnaldo Ribeiro');
    expect(model.sessions.single.start, DateTime(2030, 7, 15, 14, 30));
    expect(model.sessions.single.end, DateTime(2030, 7, 15, 15, 30));
  });
}
