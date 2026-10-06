import '../dtos/appointment_billing_dto.dart';
import '../dtos/finance_dashboard_dto.dart';
import '../dtos/new_invoice_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
///
/// Simula a API com listas em memória: pré-faturas, faturas e créditos
/// criados nesta sessão aparecem nas próximas buscas.
///
/// Regras que a API real precisa seguir:
/// - Pré-fatura só nasce de atendimento ([vincularAtendimento]). Um novo
///   atendimento do mesmo paciente e profissional soma na pré-fatura aberta.
/// - Fatura sem pré-fatura ("Novo Lançamento") vira créditos de
///   agendamento: um por sessão.
/// - Ao agendar, os créditos do paciente são usados primeiro (das faturas
///   mais antigas para as mais novas); só o que sobra vai para a pré-fatura.
/// - Finalizar a pré-fatura com mais sessões do que ela tem transforma as
///   sessões extras em créditos.
class FinanceDataSource {
  /// "Agora" da simulação (os testes fixam a data).
  final DateTime Function() _agora;

  FinanceDataSource({DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  static const _atraso = Duration(seconds: 1);

  double _pendenteMes = 4550.00;
  late final List<Map<String, dynamic>> _preFaturas = _preFaturasExemplo();

  /// Faturas lançadas. `credits_remaining`: créditos ainda não usados.
  final List<Map<String, dynamic>> _faturas = [];
  int _proximoId = 100;

  List<Map<String, dynamic>> _preFaturasExemplo() {
    final hoje = _agora();
    return [
      {
        'id': '1',
        'patient_id': '2',
        'patient_name': 'Juliana Mendes Souza',
        'professional_id': '1',
        'professional_name': 'Arnaldo Ribeiro',
        'sessions': 3,
        'created_at': hoje.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': '2',
        'patient_id': '8',
        'patient_name': 'Lucas Freitas',
        'professional_id': '3',
        'professional_name': 'Beatriz Nogueira',
        'sessions': 2,
        'created_at': hoje.subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }

  int _creditosDe(String patientId) => _faturas
      .where((f) => f['patient_id'] == patientId)
      .fold(0, (soma, f) => soma + (f['credits_remaining'] as int));

  // Simula GET /finance/dashboard com delay de 1 segundo e resposta em JSON.
  Future<FinanceDashboardDto> buscarPainel() async {
    await Future.delayed(_atraso);

    final json = {
      'month_revenue': {'received': 14200.00, 'pending': _pendenteMes},
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
      'pre_invoices': [
        for (final preFatura in _preFaturas) {...preFatura},
      ],
    };

    return FinanceDashboardDto.fromJson(json);
  }

  // Simula GET /patients/{id}/credits.
  Future<int> buscarCreditos(String patientId) async {
    await Future.delayed(_atraso);
    return _creditosDe(patientId);
  }

  // Simula POST /finance/appointments: fatura as sessões de um novo
  // atendimento (créditos primeiro, o resto na pré-fatura).
  Future<AppointmentBillingResultDto> vincularAtendimento(
    AppointmentBillingDto atendimento,
  ) async {
    await Future.delayed(_atraso);

    final json = atendimento.toJson();
    final sessoes = json['sessions'] as int;
    if (sessoes < 1) throw Exception('Atendimento sem sessões');

    // Créditos das faturas mais antigas primeiro.
    var usados = 0;
    for (final fatura in _faturas) {
      if (usados == sessoes) break;
      if (fatura['patient_id'] != json['patient_id']) continue;
      final disponiveis = fatura['credits_remaining'] as int;
      final usar = (sessoes - usados).clamp(0, disponiveis);
      fatura['credits_remaining'] = disponiveis - usar;
      usados += usar;
    }

    final pendentes = sessoes - usados;
    if (pendentes > 0) {
      final aberta = _preFaturas.where(
        (p) =>
            p['patient_id'] == json['patient_id'] &&
            p['professional_id'] == json['professional_id'],
      );
      if (aberta.isNotEmpty) {
        final preFatura = aberta.first;
        preFatura['sessions'] = (preFatura['sessions'] as int) + pendentes;
      } else {
        _preFaturas.add({
          'id': '${_proximoId++}',
          'patient_id': json['patient_id'],
          'patient_name': json['patient_name'],
          'professional_id': json['professional_id'],
          'professional_name': json['professional_name'],
          'sessions': pendentes,
          'created_at': _agora().toIso8601String(),
        });
      }
    }

    return AppointmentBillingResultDto.fromJson({
      'credits_used': usados,
      'pending_sessions': pendentes,
    });
  }

  // Simula POST /finance/invoices: lança a fatura e responde com os
  // créditos de agendamento gerados.
  Future<int> lancarFatura(NewInvoiceDto fatura) async {
    await Future.delayed(_atraso);

    final json = fatura.toJson();
    final sessoes = json['sessions'] as int;
    if (sessoes < 1) throw Exception('Informe ao menos 1 sessão');
    if ((json['session_value'] as double) <= 0) {
      throw Exception('Informe o valor da sessão');
    }

    var creditos = sessoes;
    final preFaturaId = json['pre_invoice_id'];
    if (preFaturaId != null) {
      final indice = _preFaturas.indexWhere((p) => p['id'] == preFaturaId);
      if (indice == -1) throw Exception('Pré-fatura não encontrada');

      final agendadas = _preFaturas[indice]['sessions'] as int;
      if (sessoes < agendadas) {
        throw Exception(
          'A fatura precisa cobrir as $agendadas sessões agendadas',
        );
      }
      _preFaturas.removeAt(indice);
      creditos = sessoes - agendadas;
    }

    _faturas.add({
      ...json,
      'id': '${_proximoId++}',
      'credits_remaining': creditos,
    });
    _pendenteMes += json['total'] as double;
    return creditos;
  }
}
