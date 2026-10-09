import 'package:multiclinica_app/src/features/finance/domain/models/appointment_billing_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/daily_revenue_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/finance_dashboard_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/new_invoice_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/pre_invoice_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/professional_payout_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/repositories/finance_repository.dart';

class FakeFinanceRepository implements FinanceRepository {
  bool deveFalhar;
  int quantidadeProfissionais;

  /// Pré-faturas devolvidas no painel.
  List<PreInvoiceModel> preFaturas;

  /// Créditos de agendamento por paciente.
  final Map<String, int> creditos;
  final String? erroVincular;
  final String? erroLancar;

  final List<AppointmentBillingModel> vinculados = [];
  final List<NewInvoiceModel> lancadas = [];
  int buscasPainel = 0;

  FakeFinanceRepository({
    this.deveFalhar = false,
    this.quantidadeProfissionais = 5,
    this.preFaturas = const [],
    Map<String, int>? creditos,
    this.erroVincular,
    this.erroLancar,
  }) : creditos = creditos ?? {};

  @override
  Future<FinanceDashboardModel> buscarPainel() async {
    buscasPainel++;
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
      preInvoices: preFaturas,
    );
  }

  @override
  Future<int> buscarCreditos(String patientId) async {
    return creditos[patientId] ?? 0;
  }

  /// Mesma regra da API: créditos primeiro, o resto na pré-fatura.
  @override
  Future<AppointmentBillingResult> vincularAtendimento(
    AppointmentBillingModel atendimento,
  ) async {
    final erro = erroVincular;
    if (erro != null) throw Exception(erro);
    vinculados.add(atendimento);

    final disponiveis = creditos[atendimento.patientId] ?? 0;
    final usados = atendimento.sessions.clamp(0, disponiveis);
    creditos[atendimento.patientId] = disponiveis - usados;
    return AppointmentBillingResult(
      creditsUsed: usados,
      pendingSessions: atendimento.sessions - usados,
    );
  }

  @override
  Future<int> lancarFatura(NewInvoiceModel fatura) async {
    final erro = erroLancar;
    if (erro != null) throw Exception(erro);
    lancadas.add(fatura);

    final agendadas = preFaturas
        .where((p) => p.id == fatura.preInvoiceId)
        .fold(0, (soma, p) => soma + p.sessions);
    preFaturas = [
      for (final p in preFaturas)
        if (p.id != fatura.preInvoiceId) p,
    ];
    final ganhos = fatura.sessions - agendadas;
    creditos[fatura.patientId] = (creditos[fatura.patientId] ?? 0) + ganhos;
    return ganhos;
  }
}
