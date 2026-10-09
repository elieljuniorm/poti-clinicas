import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/home/data/dtos/daily_appointment_dto.dart';
import 'package:multiclinica_app/src/features/home/data/dtos/evolution_dto.dart';
import 'package:multiclinica_app/src/features/home/data/dtos/financial_summary_dto.dart';
import 'package:multiclinica_app/src/features/home/domain/models/daily_appointment_model.dart';
import 'package:multiclinica_app/src/features/home/domain/models/evolution_model.dart';
import 'package:multiclinica_app/src/features/home/domain/models/financial_summary_model.dart';

void main() {
  group('DailyAppointmentDto', () {
    DailyAppointmentModel converter(String status) {
      return DailyAppointmentDto.fromJson({
        'patient_name': 'Jorge',
        'time': '13:30',
        'type': 'Avaliação',
        'status': status,
      }).toDomain();
    }

    test('converte os campos', () {
      final model = converter('confirmed');

      expect(model.patient, 'Jorge');
      expect(model.time, '13:30');
      expect(model.appointmentType, 'Avaliação');
    });

    test('mapeia o status, com pending como padrão', () {
      expect(converter('confirmed').status, AppointmentStatus.confirmed);
      expect(converter('canceled').status, AppointmentStatus.canceled);
      expect(converter('pending').status, AppointmentStatus.pending);
      expect(converter('desconhecido').status, AppointmentStatus.pending);
    });
  });

  group('EvolutionDto', () {
    EvolutionModel converter(String status) {
      return EvolutionDto.fromJson({
        'date': '13/02',
        'time': '10:30',
        'professional_name': 'Lucas',
        'patient_name': 'Antonia',
        'type': 'Avaliação',
        'status': status,
      }).toDomain();
    }

    test('converte os campos', () {
      final model = converter('open');

      expect(model.professional, 'Lucas');
      expect(model.patient, 'Antonia');
      expect(model.appointmentType, 'Avaliação');
    });

    test('mapeia o status, com open como padrão', () {
      expect(converter('closed').status, EvolutionStatus.closed);
      expect(converter('open').status, EvolutionStatus.open);
      expect(converter('desconhecido').status, EvolutionStatus.open);
    });
  });

  group('FinancialSummaryDto', () {
    FinancialSummaryModel converter({
      required num amount,
      String status = 'paid',
    }) {
      return FinancialSummaryDto.fromJson({
        'date': '26 Out, 2025',
        'time': '14:30',
        'patient_name': 'Carlos',
        'type': 'Avaliação',
        'payment_method': 'PIX',
        'amount': amount,
        'status': status,
      }).toDomain();
    }

    test('aceita amount inteiro ou decimal', () {
      expect(converter(amount: 350).amount, 350.0);
      expect(converter(amount: 150.5).amount, 150.5);
    });

    test('mapeia o status, com pending como padrão', () {
      expect(converter(amount: 1).status, PaymentStatus.paid);
      expect(
        converter(amount: 1, status: 'pending').status,
        PaymentStatus.pending,
      );
      expect(converter(amount: 1, status: 'x').status, PaymentStatus.pending);
    });
  });
}
