import '../dtos/finance_dashboard_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class FinanceDataSource {
  // Simula GET /finance/dashboard com delay de 1 segundo e resposta em JSON.
  Future<FinanceDashboardDto> buscarPainel() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = {
      'month_revenue': {'received': 14200.00, 'pending': 4550.00},
      'week_revenue': [
        {'day': 'Seg', 'amount': 820.00},
        {'day': 'Ter', 'amount': 930.00},
        {'day': 'Qua', 'amount': 900.00},
        {'day': 'Qui', 'amount': 930.00},
        {'day': 'Sex', 'amount': 1290.00},
        {'day': 'Sab', 'amount': 1330.00},
        {'day': 'Dom', 'amount': 1320.00},
      ],
      'professionals': [
        {
          'professional_id': '20',
          'name': 'Lucas Morais',
          'specialty': 'Fisioterapeuta',
          'photo_url': null,
          'appointments': 28,
          'week_amount': 1260.00,
          'amount_to_pay': 5880.00,
        },
        {
          'professional_id': '21',
          'name': 'Maria Clara',
          'specialty': 'Fisioterapeuta',
          'photo_url': null,
          'appointments': 22,
          'week_amount': 980.00,
          'amount_to_pay': 4620.00,
        },
        {
          'professional_id': '22',
          'name': 'João Pedro',
          'specialty': 'Fisioterapeuta',
          'photo_url': null,
          'appointments': 18,
          'week_amount': 840.00,
          'amount_to_pay': 3780.00,
        },
        {
          'professional_id': '3',
          'name': 'Beatriz Nogueira',
          'specialty': 'Terapeuta Ocupacional',
          'photo_url': null,
          'appointments': 15,
          'week_amount': 700.00,
          'amount_to_pay': 3150.00,
        },
        {
          'professional_id': '1',
          'name': 'Arnaldo Ribeiro',
          'specialty': 'Fisioterapeuta',
          'photo_url': null,
          'appointments': 12,
          'week_amount': 560.00,
          'amount_to_pay': 2520.00,
        },
      ],
    };

    return FinanceDashboardDto.fromJson(json);
  }
}
