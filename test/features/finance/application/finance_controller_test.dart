import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/finance/application/finance_controller.dart';
import 'package:multiclinica_app/src/features/finance/ui/states/finance_state.dart';

import 'fake_finance_repository.dart';

void main() {
  ProviderContainer criarContainer(FakeFinanceRepository repository) {
    return ProviderContainer.test(
      overrides: [financeRepositoryProvider.overrideWithValue(repository)],
    );
  }

  Future<ProviderContainer> carregado({int profissionais = 5}) async {
    final container = criarContainer(
      FakeFinanceRepository(quantidadeProfissionais: profissionais),
    );
    container.read(financeControllerProvider);
    await container.read(financeControllerProvider.notifier).carregar();
    return container;
  }

  test('começa carregando', () {
    final container = criarContainer(FakeFinanceRepository());

    expect(container.read(financeControllerProvider).isLoading, isTrue);
  });

  test('sucesso: painel com totais do mês', () async {
    final container = await carregado();

    final state = container.read(financeControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.dashboard!.monthTotal, 1500);
  });

  test('mostra 3 profissionais; "Ver Todos" mostra todos e volta', () async {
    final container = await carregado();
    final controller = container.read(financeControllerProvider.notifier);

    var state = container.read(financeControllerProvider);
    expect(
      state.visibleProfessionals,
      hasLength(FinanceState.profissionaisVisiveis),
    );
    expect(state.hasMoreProfessionals, isTrue);

    controller.alternarTodosProfissionais();
    state = container.read(financeControllerProvider);
    expect(state.visibleProfessionals, hasLength(5));

    // Recarregar mantém a escolha.
    await controller.carregar();
    expect(
      container.read(financeControllerProvider).visibleProfessionals,
      hasLength(5),
    );
  });

  test('com 3 ou menos profissionais não há "Ver Todos"', () async {
    final container = await carregado(profissionais: 2);

    expect(
      container.read(financeControllerProvider).hasMoreProfessionals,
      isFalse,
    );
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(FakeFinanceRepository(deveFalhar: true));

    container.read(financeControllerProvider);
    await container.read(financeControllerProvider.notifier).carregar();

    final state = container.read(financeControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar financeiro'));
  });
}
