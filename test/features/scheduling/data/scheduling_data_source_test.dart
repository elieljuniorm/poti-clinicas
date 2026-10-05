import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/data/data_sources/scheduling_remote_data_source.dart';
import 'package:poti_5f/src/features/scheduling/data/dtos/new_appointment_dto.dart';
import 'package:poti_5f/src/features/scheduling/data/dtos/scheduling_appointment_dto.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/new_appointment_model.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_appointment_model.dart';

void main() {
  // Quarta, 15/07/2026: semana de 12 (dom) a 18 (sáb).
  final agora = DateTime(2026, 7, 15, 9);
  SchedulingDataSource dataSource() => SchedulingDataSource(agora: () => agora);

  Future<List<SchedulingAppointmentModel>> buscar(
    SchedulingDataSource ds,
    String periodo,
  ) async =>
      (await ds.buscarAtendimentos(periodo)).map((d) => d.toDomain()).toList();

  NewAppointmentDto agendamento(List<(DateTime, DateTime)> sessoes) {
    return NewAppointmentDto.fromDomain(
      NewAppointmentModel(
        patientId: '2',
        patientName: 'Juliana Mendes Souza',
        professionalId: '1',
        professionalName: 'Dr. Arnaldo Ribeiro',
        appointmentType: 'Avaliação',
        sessions: [
          for (final (inicio, fim) in sessoes)
            AppointmentSessionModel(start: inicio, end: fim),
        ],
      ),
    );
  }

  group('filtro por período', () {
    test('dia: só hoje, em ordem de horário', () async {
      final lista = await buscar(dataSource(), 'day');

      expect(lista, isNotEmpty);
      expect(lista.every((a) => a.date == '15/07'), isTrue);
      final horarios = lista.map((a) => a.start).toList();
      expect(horarios, [...horarios]..sort());
    });

    test('semana: de domingo a sábado; mês: o mês todo', () async {
      final ds = dataSource();
      final semana = await buscar(ds, 'week');
      final mes = await buscar(ds, 'month');

      for (final a in semana) {
        expect(a.start.isBefore(DateTime(2026, 7, 12)), isFalse);
        expect(a.start.isBefore(DateTime(2026, 7, 19)), isTrue);
      }
      expect(mes.every((a) => a.start.month == 7), isTrue);
      expect(mes.length, greaterThan(semana.length));
    });
  });

  group('cascata do agendamento', () {
    test('cada sessão vira um atendimento próprio, pendente', () async {
      final ds = dataSource();
      final antes = (await buscar(ds, 'month')).length;

      await ds.agendar(
        agendamento([
          (DateTime(2026, 7, 20, 14, 30), DateTime(2026, 7, 20, 15, 30)),
          (DateTime(2026, 7, 22, 14, 30), DateTime(2026, 7, 22, 15, 30)),
        ]),
      );

      final mes = await buscar(ds, 'month');
      final novos = mes.where((a) => a.date == '20/07' || a.date == '22/07');
      expect(mes, hasLength(antes + 2));
      expect(novos, hasLength(2));
      expect(novos.map((a) => a.id).toSet(), hasLength(2)); // ids diferentes
      expect(novos.every((a) => a.status == AppointmentStatus.pending), isTrue);
      expect(novos.first.patient, 'Juliana Mendes Souza');
    });

    test('recusa sessão que termina antes de começar', () {
      expect(
        () => dataSource().agendar(
          agendamento([
            (DateTime(2026, 7, 20, 14, 30), DateTime(2026, 7, 20, 14, 0)),
          ]),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('edição de um atendimento', () {
    test('substitui só aquele atendimento', () async {
      final ds = dataSource();
      final hoje = await buscar(ds, 'day');
      final alvo = hoje.first;

      await ds.atualizarAtendimento(
        SchedulingAppointmentDto.fromDomain(
          alvo.copyWith(
            status: AppointmentStatus.confirmed,
            start: DateTime(2026, 7, 16, 8),
            end: DateTime(2026, 7, 16, 9),
          ),
        ),
      );

      final depoisHoje = await buscar(ds, 'day');
      final semana = await buscar(ds, 'week');
      expect(depoisHoje.any((a) => a.id == alvo.id), isFalse); // saiu de hoje
      final movido = semana.firstWhere((a) => a.id == alvo.id);
      expect(movido.date, '16/07');
      expect(movido.status, AppointmentStatus.confirmed);
      expect(depoisHoje, hasLength(hoje.length - 1));
    });

    test('atendimento inexistente ou horário inválido é recusado', () async {
      final ds = dataSource();
      final alvo = (await buscar(ds, 'day')).first;

      expect(
        () => ds.atualizarAtendimento(
          SchedulingAppointmentDto.fromDomain(alvo).copyComId('nao-existe'),
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => ds.atualizarAtendimento(
          SchedulingAppointmentDto.fromDomain(
            alvo.copyWith(end: alvo.start.subtract(const Duration(hours: 1))),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

extension on SchedulingAppointmentDto {
  SchedulingAppointmentDto copyComId(String id) =>
      SchedulingAppointmentDto.fromJson({...toJson(), 'id': id});
}
