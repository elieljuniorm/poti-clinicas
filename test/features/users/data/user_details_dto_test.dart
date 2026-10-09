import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/users/data/dtos/user_details_dto.dart';

void main() {
  group('UserDetailsDto', () {
    test('paciente: contrato, sessões e consumo', () {
      final model = UserDetailsDto.fromJson({
        'contract': {
          'name': 'Pacote Domiciliar',
          'start_date': '15/03/2025',
          'end_date': '15/09/2025',
          'status': 'active',
          'file_name': 'Contrato de Serviços.pdf',
        },
        'recent_sessions': [
          {
            'title': 'Sessão',
            'date': '12/07/2025',
            'note': 'Evolução positiva',
          },
        ],
        'consumption': {
          'contracted': 20,
          'performed': 12,
          'session_value': 180,
          'payment_method': 'PIX',
        },
      }).toDomain();

      expect(model.contract!.name, 'Pacote Domiciliar');
      expect(model.contract!.active, isTrue);
      expect(model.recentSessions.single.note, 'Evolução positiva');
      expect(model.consumption!.available, 8);
      expect(model.consumption!.progress, 0.6);
      expect(model.consumption!.totalValue, 3600);
      expect(model.professionalInfo, isNull);
      expect(model.accessInfo, isNull);
    });

    test('contrato com status diferente de active fica inativo', () {
      final model = UserDetailsDto.fromJson({
        'contract': {
          'name': 'Pacote',
          'start_date': '10/01/2025',
          'end_date': '10/04/2025',
          'status': 'expired',
        },
      }).toDomain();

      expect(model.contract!.active, isFalse);
      expect(model.contract!.fileName, isNull);
    });

    test('profissional: dados, próximos atendimentos e resumo', () {
      final model = UserDetailsDto.fromJson({
        'professional_info': {
          'specialty': 'Fisioterapeuta',
          'registry': 'CREFITO-12',
          'bond': 'CLT',
          'since': '10/01/2023',
        },
        'upcoming_appointments': [
          {
            'date': '02/02',
            'time': '08:30',
            'patient_name': 'Jorge',
            'type': 'Avaliação',
          },
        ],
        'month_summary': {
          'performed': 42,
          'scheduled': 18,
          'active_patients': 23,
        },
      }).toDomain();

      expect(model.professionalInfo!.specialty, 'Fisioterapeuta');
      expect(model.upcomingAppointments.single.patient, 'Jorge');
      expect(model.monthSummary!.activePatients, 23);
      expect(model.contract, isNull);
    });

    test('sem blocos: detalhes vazios', () {
      expect(UserDetailsDto.fromJson({}).toDomain().isEmpty, isTrue);
    });
  });
}
