import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/data/dtos/scheduling_appointment_dto.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_appointment_model.dart';

import '../application/appointment_fixture.dart';

void main() {
  group('SchedulingAppointmentDto', () {
    Map<String, dynamic> json(String status) => {
      'id': '7',
      'patient_id': '2',
      'patient_name': 'Juliana Mendes Souza',
      'professional_id': '1',
      'professional_name': 'Dr. Arnaldo Ribeiro',
      'type': 'Avaliação',
      'clinical_case': 'Dor lombar',
      'start': '2025-07-15T14:30:00.000',
      'end': '2025-07-15T15:30:00.000',
      'status': status,
    };

    test('converte os campos e as datas', () {
      final model = SchedulingAppointmentDto.fromJson(json('confirmed'))
          .toDomain();

      expect(model.id, '7');
      expect(model.patientId, '2');
      expect(model.patient, 'Juliana Mendes Souza');
      expect(model.professional, 'Dr. Arnaldo Ribeiro');
      expect(model.clinicalCase, 'Dor lombar');
      expect(model.start, DateTime(2025, 7, 15, 14, 30));
      // Colunas da tabela.
      expect(model.date, '15/07');
      expect(model.time, '14:30');
    });

    test('mapeia o status, com pending como padrão', () {
      AppointmentStatus status(String s) =>
          SchedulingAppointmentDto.fromJson(json(s)).toDomain().status;

      expect(status('confirmed'), AppointmentStatus.confirmed);
      expect(status('canceled'), AppointmentStatus.canceled);
      expect(status('pending'), AppointmentStatus.pending);
      expect(status('desconhecido'), AppointmentStatus.pending);
    });

    test('ida e volta (edição) preserva tudo; caso vazio não é enviado', () {
      final original = atendimentoDeTeste(
        status: AppointmentStatus.canceled,
        clinicalCase: '  ',
      );
      final dto = SchedulingAppointmentDto.fromDomain(original);
      final volta = SchedulingAppointmentDto.fromJson(dto.toJson()).toDomain();

      expect(dto.toJson()['status'], 'canceled');
      expect(dto.toJson().containsKey('clinical_case'), isFalse);
      expect(volta.start, original.start);
      expect(volta.end, original.end);
      expect(volta.status, AppointmentStatus.canceled);
    });
  });
}
