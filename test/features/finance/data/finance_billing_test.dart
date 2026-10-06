import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/finance/data/data_sources/finance_remote_data_source.dart';
import 'package:poti_5f/src/features/finance/data/dtos/appointment_billing_dto.dart';
import 'package:poti_5f/src/features/finance/data/dtos/new_invoice_dto.dart';
import 'package:poti_5f/src/features/finance/domain/models/appointment_billing_model.dart';
import 'package:poti_5f/src/features/finance/domain/models/finance_dashboard_model.dart';
import 'package:poti_5f/src/features/finance/domain/models/new_invoice_model.dart';

/// Regras de faturamento da API simulada: pré-fatura só a partir de
/// atendimento, créditos de agendamento a partir de fatura avulsa.
void main() {
  final agora = DateTime(2026, 7, 15, 9);
  late FinanceDataSource ds;

  setUp(() => ds = FinanceDataSource(agora: () => agora));

  /// Roda a chamada pulando o delay simulado.
  T rodar<T>(Future<T> Function() chamada) {
    late T resultado;
    Object? erro;
    fakeAsync((async) {
      chamada().then<void>(
        (r) => resultado = r,
        onError: (Object e) => erro = e,
      );
      async.elapse(const Duration(seconds: 2));
    });
    if (erro != null) throw erro!;
    return resultado;
  }

  FinanceDashboardModel painel() => rodar(ds.buscarPainel).toDomain();

  int creditos(String patientId) => rodar(() => ds.buscarCreditos(patientId));

  AppointmentBillingResult agendar({
    String patientId = '20',
    String professionalId = '1',
    required int sessoes,
  }) {
    return rodar(
      () => ds.vincularAtendimento(
        AppointmentBillingDto.fromDomain(
          AppointmentBillingModel(
            patientId: patientId,
            patientName: 'Ana Paciente',
            professionalId: professionalId,
            professionalName: 'Arnaldo Ribeiro',
            sessions: sessoes,
          ),
        ),
      ),
    ).toDomain();
  }

  int lancar({String? preInvoiceId, required int sessoes, double valor = 100}) {
    return rodar(
      () => ds.lancarFatura(
        NewInvoiceDto.fromDomain(
          NewInvoiceModel(
            preInvoiceId: preInvoiceId,
            patientId: '20',
            patientName: 'Ana Paciente',
            professionalId: '1',
            professionalName: 'Arnaldo Ribeiro',
            type: InvoiceType.clinicPackage,
            sessions: sessoes,
            sessionValue: valor,
            paymentMethod: PaymentMethod.pix,
          ),
        ),
      ),
    );
  }

  List<String> preFaturasDaAna() => [
    for (final p in painel().preInvoices)
      if (p.patientId == '20') p.id,
  ];

  int sessoesNaPreFatura() =>
      painel().preInvoices.where((p) => p.patientId == '20').single.sessions;

  test('o painel traz as pré-faturas de exemplo', () {
    final preFaturas = painel().preInvoices;

    expect(preFaturas, hasLength(2));
    expect(preFaturas.first.patientName, 'Juliana Mendes Souza');
    expect(preFaturas.first.professionalName, 'Arnaldo Ribeiro');
    expect(preFaturas.first.sessions, 3);
  });

  group('atendimento sem créditos', () {
    test('todas as sessões vão para uma pré-fatura nova', () {
      final resultado = agendar(sessoes: 4);

      expect(resultado.creditsUsed, 0);
      expect(resultado.pendingSessions, 4);
      expect(sessoesNaPreFatura(), 4);
    });

    test('mesmo paciente e profissional somam na pré-fatura aberta', () {
      agendar(sessoes: 4);
      agendar(sessoes: 2);

      expect(preFaturasDaAna(), hasLength(1));
      expect(sessoesNaPreFatura(), 6);
    });

    test('outro profissional gera outra pré-fatura', () {
      agendar(sessoes: 4);
      agendar(sessoes: 2, professionalId: '3');

      expect(preFaturasDaAna(), hasLength(2));
    });
  });

  group('fatura sem atendimento ("Novo Lançamento")', () {
    test('as sessões viram créditos de agendamento', () {
      expect(lancar(sessoes: 5), 5);
      expect(creditos('20'), 5);
      expect(preFaturasDaAna(), isEmpty);
    });

    test('créditos cobrem o atendimento inteiro: sem pré-fatura', () {
      lancar(sessoes: 5);

      final resultado = agendar(sessoes: 3);

      expect(resultado.creditsUsed, 3);
      expect(resultado.pendingSessions, 0);
      expect(creditos('20'), 2);
      expect(preFaturasDaAna(), isEmpty);
    });

    test('créditos de várias faturas somam; o que falta vai para a '
        'pré-fatura', () {
      lancar(sessoes: 2);
      lancar(sessoes: 1);

      final resultado = agendar(sessoes: 5);

      expect(resultado.creditsUsed, 3);
      expect(resultado.pendingSessions, 2);
      expect(creditos('20'), 0);
      expect(sessoesNaPreFatura(), 2);
    });

    test('créditos são do paciente: não servem para outro', () {
      lancar(sessoes: 5);

      final resultado = agendar(patientId: '21', sessoes: 2);

      expect(resultado.creditsUsed, 0);
      expect(creditos('20'), 5);
    });

    test('soma o total no pendente do mês', () {
      final antes = painel().monthPending;

      lancar(sessoes: 4, valor: 150);

      expect(painel().monthPending, antes + 600);
    });
  });

  group('finalizar pré-fatura', () {
    test('some do painel e não gera créditos', () {
      agendar(sessoes: 4);
      final id = preFaturasDaAna().single;

      expect(lancar(preInvoiceId: id, sessoes: 4), 0);

      expect(preFaturasDaAna(), isEmpty);
      expect(creditos('20'), 0);
    });

    test('sessões além das agendadas viram créditos', () {
      agendar(sessoes: 4);
      final id = preFaturasDaAna().single;

      expect(lancar(preInvoiceId: id, sessoes: 6), 2);
      expect(creditos('20'), 2);
    });

    test('menos sessões que as agendadas é recusado', () {
      agendar(sessoes: 4);
      final id = preFaturasDaAna().single;

      expect(
        () => lancar(preInvoiceId: id, sessoes: 3),
        throwsA(
          isA<Exception>().having(
            (e) => '$e',
            'mensagem',
            contains('4 sessões agendadas'),
          ),
        ),
      );
      expect(preFaturasDaAna(), [id]);
    });

    test('pré-fatura inexistente ou valor zerado é recusado', () {
      expect(
        () => lancar(preInvoiceId: 'x', sessoes: 1),
        throwsA(isA<Exception>()),
      );
      expect(() => lancar(sessoes: 1, valor: 0), throwsA(isA<Exception>()));
    });
  });
}
