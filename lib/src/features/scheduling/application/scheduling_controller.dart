import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/scheduling_remote_data_source.dart';
import '../data/repository/scheduling_repository_impl.dart';
import '../domain/models/scheduling_period.dart';
import '../domain/repositories/scheduling_repository.dart';
import '../ui/states/scheduling_state.dart';

class SchedulingController extends Notifier<SchedulingState> {
  SchedulingRepository get _repository =>
      ref.read(schedulingRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  SchedulingState build() {
    Future.microtask(carregar);
    return const SchedulingState(isLoading: true);
  }

  /// Troca o filtro e recarrega os atendimentos do novo período.
  Future<void> selecionarPeriodo(SchedulingPeriod periodo) async {
    if (periodo == state.period) return;

    state = state.copyWith(period: periodo);
    await carregar();
  }

  Future<void> carregar() async {
    final periodo = state.period;
    state = state.copyWith(isLoading: true);

    try {
      final atendimentos = await _repository.buscarAtendimentos(periodo);
      // Ignora a resposta se o filtro mudou durante a busca.
      if (!ref.mounted || state.period != periodo) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = SchedulingState(period: periodo, appointments: atendimentos);
    } catch (e) {
      if (!ref.mounted || state.period != periodo) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar agenda: $e',
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

final schedulingDataSourceProvider = Provider<SchedulingDataSource>(
  (ref) => SchedulingDataSource(),
);

final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  return SchedulingRepositoryImpl(ref.watch(schedulingDataSourceProvider));
});

final schedulingControllerProvider =
    NotifierProvider<SchedulingController, SchedulingState>(
      SchedulingController.new,
    );
