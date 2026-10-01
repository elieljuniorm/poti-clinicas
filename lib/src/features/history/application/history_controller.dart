import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/history_remote_data_source.dart';
import '../data/repository/history_repository_impl.dart';
import '../domain/models/history_tab.dart';
import '../domain/repositories/history_repository.dart';
import '../ui/states/history_state.dart';

class HistoryController extends Notifier<HistoryState> {
  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  HistoryState build() {
    Future.microtask(carregar);
    return const HistoryState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      // As duas buscas rodam em paralelo.
      final (atendimentos, lancamentos) = await (
        _repository.buscarAtendimentos(),
        _repository.buscarLancamentos(),
      ).wait;
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      // A aba escolhida é mantida.
      state = HistoryState(
        tab: state.tab,
        appointments: atendimentos,
        entries: lancamentos,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar histórico: $e',
      );
    }
  }

  void selecionarAba(HistoryTab aba) {
    state = state.copyWith(tab: aba);
  }

  /// "Ver Todos" / "Ver Menos" dos lançamentos recentes.
  void alternarTodosLancamentos() {
    state = state.copyWith(showAllEntries: !state.showAllEntries);
  }
}

// ============================================================
// Providers
// ============================================================

final historyDataSourceProvider = Provider<HistoryDataSource>(
  (ref) => HistoryDataSource(),
);

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.watch(historyDataSourceProvider));
});

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);
