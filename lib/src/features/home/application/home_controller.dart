import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/home_remote_data_source.dart';
import '../data/repository/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../ui/states/home_state.dart';

class HomeController extends Notifier<HomeState> {
  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  HomeState build() {
    Future.microtask(carregar);
    return const HomeState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      // As três buscas rodam em paralelo.
      final (dailyAppointments, evolutions, financialSummaries) = await (
        _repository.buscarAtendimentosDoDia(),
        _repository.buscarEvolucoes(),
        _repository.buscarResumoFinanceiro(),
      ).wait;

      // Estado novo: garante que um erro anterior seja limpo.
      state = HomeState(
        dailyAppointments: dailyAppointments,
        evolutions: evolutions,
        financialSummaries: financialSummaries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados: $e',
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

final homeDataSourceProvider = Provider<HomeDataSource>(
  (ref) => HomeDataSource(),
);

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(homeDataSourceProvider));
});

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
