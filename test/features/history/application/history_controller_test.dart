import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/history/application/history_controller.dart';
import 'package:multiclinica_app/src/features/history/domain/models/history_tab.dart';
import 'package:multiclinica_app/src/features/history/ui/states/history_state.dart';

import 'fake_history_repository.dart';

void main() {
  ProviderContainer criarContainer(FakeHistoryRepository repository) {
    return ProviderContainer.test(
      overrides: [historyRepositoryProvider.overrideWithValue(repository)],
    );
  }

  Future<ProviderContainer> carregado({int lancamentos = 5}) async {
    final container = criarContainer(
      FakeHistoryRepository(quantidadeLancamentos: lancamentos),
    );
    container.read(historyControllerProvider);
    await container.read(historyControllerProvider.notifier).carregar();
    return container;
  }

  test('começa carregando na aba "Atendimentos"', () {
    final container = criarContainer(FakeHistoryRepository());

    final state = container.read(historyControllerProvider);
    expect(state.isLoading, isTrue);
    expect(state.tab, HistoryTab.appointments);
  });

  test('sucesso: atendimentos, lançamentos e totais', () async {
    final container = await carregado();

    final state = container.read(historyControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.appointments, hasLength(2));
    expect(state.entries, hasLength(5));
    expect(state.overview.received, 300); // 1, 3 e 5 pagos
    expect(state.overview.pending, 200); // 2 e 4 pendentes
  });

  test('recentes mostra 3; "Ver Todos" mostra todos e volta', () async {
    final container = await carregado();
    final controller = container.read(historyControllerProvider.notifier);

    var state = container.read(historyControllerProvider);
    expect(state.visibleEntries, hasLength(HistoryState.lancamentosRecentes));
    expect(state.hasMoreEntries, isTrue);

    controller.alternarTodosLancamentos();
    state = container.read(historyControllerProvider);
    expect(state.visibleEntries, hasLength(5));

    controller.alternarTodosLancamentos();
    expect(
      container.read(historyControllerProvider).visibleEntries,
      hasLength(3),
    );
  });

  test('com 3 ou menos lançamentos não há "Ver Todos"', () async {
    final container = await carregado(lancamentos: 3);

    expect(container.read(historyControllerProvider).hasMoreEntries, isFalse);
  });

  test('a aba escolhida é mantida ao recarregar', () async {
    final container = await carregado();
    final controller = container.read(historyControllerProvider.notifier);

    controller.selecionarAba(HistoryTab.entries);
    await controller.carregar();

    expect(container.read(historyControllerProvider).tab, HistoryTab.entries);
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(FakeHistoryRepository(deveFalhar: true));

    container.read(historyControllerProvider);
    await container.read(historyControllerProvider.notifier).carregar();

    final state = container.read(historyControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar histórico'));
  });
}
