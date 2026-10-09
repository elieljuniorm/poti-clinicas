import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/finance/application/finance_controller.dart';
import 'package:multiclinica_app/src/features/finance/application/new_invoice_controller.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/new_invoice_model.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/pre_invoice_model.dart';
import 'package:multiclinica_app/src/features/finance/ui/states/new_invoice_state.dart';

import 'fake_finance_repository.dart';

void main() {
  final preFatura = PreInvoiceModel(
    id: '7',
    patientId: '2',
    patientName: 'Juliana Mendes Souza',
    professionalId: '1',
    professionalName: 'Arnaldo Ribeiro',
    sessions: 3,
    createdAt: DateTime(2026, 7, 15),
  );

  NewInvoiceModel fatura({String? preInvoiceId, int sessoes = 3}) {
    return NewInvoiceModel(
      preInvoiceId: preInvoiceId,
      patientId: '2',
      patientName: 'Juliana Mendes Souza',
      professionalId: '1',
      professionalName: 'Arnaldo Ribeiro',
      type: InvoiceType.clinicPackage,
      sessions: sessoes,
      sessionValue: 150,
      paymentMethod: PaymentMethod.pix,
    );
  }

  ProviderContainer criarContainer(FakeFinanceRepository repository) {
    final container = ProviderContainer.test(
      overrides: [financeRepositoryProvider.overrideWithValue(repository)],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(newInvoiceControllerProvider, (_, _) {});
    return container;
  }

  test('começa no estado inicial', () {
    final container = criarContainer(FakeFinanceRepository());

    expect(
      container.read(newInvoiceControllerProvider),
      isA<NewInvoiceInitial>(),
    );
  });

  test('fatura avulsa: sucesso com os créditos gerados', () async {
    final repository = FakeFinanceRepository();
    final container = criarContainer(repository);

    await container
        .read(newInvoiceControllerProvider.notifier)
        .lancar(fatura(sessoes: 5));

    final state = container.read(newInvoiceControllerProvider);
    expect(state, isA<NewInvoiceSuccess>());
    expect((state as NewInvoiceSuccess).credits, 5);
    expect(repository.lancadas.single.total, 750);
  });

  test('finalizar pré-fatura recarrega o painel aberto sem ela', () async {
    final repository = FakeFinanceRepository(preFaturas: [preFatura]);
    final container = criarContainer(repository);
    container.read(financeControllerProvider);
    await container.read(financeControllerProvider.notifier).carregar();
    expect(
      container.read(financeControllerProvider.notifier).preFatura('7'),
      isNotNull,
    );

    await container
        .read(newInvoiceControllerProvider.notifier)
        .lancar(fatura(preInvoiceId: '7'));
    await Future<void>.delayed(Duration.zero);

    expect(
      (container.read(
        newInvoiceControllerProvider,
      ) as NewInvoiceSuccess).credits,
      0,
    );
    expect(
      container.read(financeControllerProvider.notifier).preFatura('7'),
      isNull,
    );
  });

  test('os créditos do paciente são buscados de novo depois', () async {
    final repository = FakeFinanceRepository();
    final container = criarContainer(repository);
    container.listen(patientCreditsProvider('2'), (_, _) {});
    expect(await container.read(patientCreditsProvider('2').future), 0);

    await container
        .read(newInvoiceControllerProvider.notifier)
        .lancar(fatura(sessoes: 4));

    expect(await container.read(patientCreditsProvider('2').future), 4);
  });

  test('erro: mensagem sem o prefixo "Exception:"', () async {
    final container = criarContainer(
      FakeFinanceRepository(erroLancar: 'Pré-fatura não encontrada'),
    );

    await container
        .read(newInvoiceControllerProvider.notifier)
        .lancar(fatura());

    final state = container.read(newInvoiceControllerProvider);
    expect(state, isA<NewInvoiceError>());
    expect((state as NewInvoiceError).message, 'Pré-fatura não encontrada');
  });
}
