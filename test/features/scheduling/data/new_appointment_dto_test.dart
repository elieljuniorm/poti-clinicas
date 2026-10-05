import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/data/data_sources/scheduling_remote_data_source.dart';
import 'package:poti_5f/src/features/scheduling/data/dtos/new_appointment_dto.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/new_appointment_model.dart';

NewAppointmentModel agendamento({String? caso, DateTime? fim}) {
  return NewAppointmentModel(
    patientId: '2',
    professionalId: '1',
    appointmentType: 'Avaliação',
    clinicalCase: caso,
    sessions: [
      AppointmentSessionModel(
        start: DateTime(2025, 7, 15, 14, 30),
        end: fim ?? DateTime(2025, 7, 15, 15, 30),
      ),
    ],
  );
}

void main() {
  group('NewAppointmentDto', () {
    test('envia ids, tipo e sessões em ISO 8601', () {
      final json = NewAppointmentDto.fromDomain(
        agendamento(caso: ' Dor lombar '),
      ).toJson();

      expect(json['patient_id'], '2');
      expect(json['professional_id'], '1');
      expect(json['type'], 'Avaliação');
      expect(json['clinical_case'], 'Dor lombar');
      expect(json['sessions'], [
        {'start': '2025-07-15T14:30:00.000', 'end': '2025-07-15T15:30:00.000'},
      ]);
    });

    test('caso clínico vazio não é enviado', () {
      final json = NewAppointmentDto.fromDomain(agendamento(caso: '  '))
          .toJson();

      expect(json.containsKey('clinical_case'), isFalse);
    });
  });

  group('SchedulingDataSource.agendar', () {
    test('guarda o agendamento', () async {
      final dataSource = SchedulingDataSource();

      await dataSource.agendar(NewAppointmentDto.fromDomain(agendamento()));

      expect(dataSource.agendados, hasLength(1));
    });

    test('recusa sessão que termina antes de começar', () {
      final dataSource = SchedulingDataSource();

      expect(
        () => dataSource.agendar(
          NewAppointmentDto.fromDomain(
            agendamento(fim: DateTime(2025, 7, 15, 14, 0)),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
