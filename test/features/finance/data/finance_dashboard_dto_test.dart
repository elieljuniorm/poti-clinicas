import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/finance/data/data_sources/finance_remote_data_source.dart';
import 'package:poti_5f/src/features/finance/data/dtos/finance_dashboard_dto.dart';

void main() {
  group('FinanceDashboardDto', () {
    test('converte mês, semana e profissionais', () {
      final model = FinanceDashboardDto.fromJson({
        'month_revenue': {'received': 100, 'pending': 50.5},
        'week_revenue': [
          {'day': 'Seg', 'amount': 820},
        ],
        'professionals': [
          {
            'professional_id': '20',
            'name': 'Lucas Morais',
            'specialty': 'Fisioterapeuta',
            'appointments': 28,
            'week_amount': 1260,
            'amount_to_pay': 5880,
          },
        ],
      }).toDomain();

      expect(model.monthReceived, 100);
      expect(model.monthPending, 50.5);
      expect(model.monthTotal, 150.5);
      expect(model.week.single.day, 'Seg');
      expect(model.week.single.amount, 820);
      final profissional = model.professionals.single;
      expect(profissional.name, 'Lucas Morais');
      expect(profissional.appointments, 28);
      expect(profissional.amountToPay, 5880);
      expect(profissional.photoUrl, isNull);
    });

    test('blocos ausentes viram zero e listas vazias', () {
      final model = FinanceDashboardDto.fromJson({}).toDomain();

      expect(model.monthTotal, 0);
      expect(model.week, isEmpty);
      expect(model.professionals, isEmpty);
    });
  });

  test('mock fecha com o modelo (R\$ 18.750 / 14.200 / 4.550)', () async {
    final model = (await FinanceDataSource().buscarPainel()).toDomain();

    expect(model.monthTotal, 18750);
    expect(model.monthReceived, 14200);
    expect(model.monthPending, 4550);
    expect(model.week.map((d) => d.day), [
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sab',
      'Dom',
    ]);
  });
}
