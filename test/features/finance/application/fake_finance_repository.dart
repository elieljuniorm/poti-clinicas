import 'package:poti_5f/src/features/finance/domain/models/daily_revenue_model.dart';
import 'package:poti_5f/src/features/finance/domain/models/finance_dashboard_model.dart';
import 'package:poti_5f/src/features/finance/domain/models/professional_payout_model.dart';
import 'package:poti_5f/src/features/finance/domain/repositories/finance_repository.dart';

class FakeFinanceRepository implements FinanceRepository {
  bool deveFalhar;
  int quantidadeProfissionais;

  FakeFinanceRepository({
    this.deveFalhar = false,
    this.quantidadeProfissionais = 5,
  });

  @override
  Future<FinanceDashboardModel> buscarPainel() async {
    if (deveFalhar) throw Exception('sem conexão');
    return FinanceDashboardModel(
      monthReceived: 1000,
      monthPending: 500,
      week: const [
        DailyRevenueModel(day: 'Seg', amount: 100),
        DailyRevenueModel(day: 'Ter', amount: 200),
      ],
      professionals: [
        for (var i = 1; i <= quantidadeProfissionais; i++)
          ProfessionalPayoutModel(
            professionalId: '$i',
            name: 'Profissional $i',
            specialty: 'Fisioterapeuta',
            appointments: i,
            weekAmount: 100,
            amountToPay: 1000.0 * i,
          ),
      ],
    );
  }
}
