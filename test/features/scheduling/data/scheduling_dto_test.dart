import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/data/dtos/scheduling_appointment_dto.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_appointment_model.dart';

void main() {
  group('SchedulingAppointmentDto', () {
    SchedulingAppointmentModel converter(String status) {
      return SchedulingAppointmentDto.fromJson({
        'date': '02/02',
        'time': '08:30',
        'patient_name': 'Jorge Silva',
        'type': 'Avaliação',
        'status': status,
      }).toDomain();
    }

    test('converte os campos', () {
      final model = converter('confirmed');

      expect(model.date, '02/02');
      expect(model.time, '08:30');
      expect(model.patient, 'Jorge Silva');
      expect(model.appointmentType, 'Avaliação');
    });

    test('mapeia o status, com pending como padrão', () {
      expect(converter('confirmed').status, AppointmentStatus.confirmed);
      expect(converter('canceled').status, AppointmentStatus.canceled);
      expect(converter('pending').status, AppointmentStatus.pending);
      expect(converter('desconhecido').status, AppointmentStatus.pending);
    });
  });
}
