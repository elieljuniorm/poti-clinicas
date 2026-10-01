import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/history/data/data_sources/history_remote_data_source.dart';
import 'package:poti_5f/src/features/history/data/dtos/appointment_history_dto.dart';
import 'package:poti_5f/src/features/history/domain/models/appointment_history_model.dart';
import 'package:poti_5f/src/features/history/domain/models/appointment_history_status.dart';
import 'package:poti_5f/src/features/history/domain/models/financial_overview_model.dart';

void main() {
  group('AppointmentHistoryDto', () {
    AppointmentHistoryModel converter(String status) {
      return AppointmentHistoryDto.fromJson({
        'date': '24 Out, 2025',
        'time': '14:30',
        'patient_name': 'Jorge Silva',
        'type': 'Avaliação',
        'professional_name': 'Lucas Meireles',
        'status': status,
      }).toDomain();
    }

    test('converte os campos', () {
      final model = converter('confirmed');

      expect(model.date, '24 Out, 2025');
      expect(model.time, '14:30');
      expect(model.patient, 'Jorge Silva');
      expect(model.appointmentType, 'Avaliação');
      expect(model.professional, 'Lucas Meireles');
    });

    test('mapeia o status, com confirmed como padrão', () {
      expect(converter('confirmed').status, AppointmentHistoryStatus.confirmed);
      expect(converter('performed').status, AppointmentHistoryStatus.performed);
      expect(converter('canceled').status, AppointmentHistoryStatus.canceled);
      expect(converter('?').status, AppointmentHistoryStatus.confirmed);
    });
  });

  test(
    'mock de lançamentos fecha com o modelo (R\$ 2.450 / 1.650 / 800)',
    () async {
      final dtos = await HistoryDataSource().buscarLancamentos();
      final overview = FinancialOverviewModel.fromEntries(
        dtos.map((d) => d.toDomain()).toList(),
      );

      expect(overview.total, 2450);
      expect(overview.received, 1650);
      expect(overview.pending, 800);
    },
  );
}
