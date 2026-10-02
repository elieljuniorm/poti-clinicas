import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/finance_remote_data_source.dart';
import '../data/repository/finance_repository_impl.dart';
import '../domain/repositories/finance_repository.dart';
import '../ui/states/finance_state.dart';

class FinanceController extends Notifier<FinanceState> {
  FinanceRepository get _repository => ref.read(financeRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  FinanceState build() {
    Future.microtask(carregar);
    return const FinanceState(isLoading: true);
  }

  /// Busca o painel. Chamado de novo quando um lançamento for criado.
  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final painel = await _repository.buscarPainel();
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = FinanceState(
        dashboard: painel,
        showAllProfessionals: state.showAllProfessionals,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar financeiro: $e',
      );
    }
  }

  /// "Ver Todos" / "Ver Menos" dos profissionais.
  void alternarTodosProfissionais() {
    state = state.copyWith(showAllProfessionals: !state.showAllProfessionals);
  }
}

// ============================================================
// Providers
// ============================================================

final financeDataSourceProvider = Provider<FinanceDataSource>(
  (ref) => FinanceDataSource(),
);

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepositoryImpl(ref.watch(financeDataSourceProvider));
});

final financeControllerProvider =
    NotifierProvider<FinanceController, FinanceState>(FinanceController.new);
