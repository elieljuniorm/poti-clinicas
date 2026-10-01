import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/medical_records_remote_data_source.dart';
import '../data/repository/medical_records_repository_impl.dart';
import '../domain/models/medical_record_filter.dart';
import '../domain/repositories/medical_records_repository.dart';
import '../ui/states/medical_records_state.dart';

class MedicalRecordsController extends Notifier<MedicalRecordsState> {
  MedicalRecordsRepository get _repository =>
      ref.read(medicalRecordsRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  MedicalRecordsState build() {
    Future.microtask(carregar);
    return const MedicalRecordsState(isLoading: true);
  }

  /// Busca a lista. Chamado de novo quando outra tela mudar um prontuário
  /// (criar registro, registrar evolução, dar alta).
  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final prontuarios = await _repository.buscarProntuarios();
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      // Filtro e busca são mantidos.
      state = MedicalRecordsState(
        records: prontuarios,
        filter: state.filter,
        search: state.search,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar prontuários: $e',
      );
    }
  }

  /// Filtro e busca são aplicados em memória
  /// (ver [MedicalRecordsState.filteredRecords]).
  void selecionarFiltro(MedicalRecordFilter filtro) {
    state = state.copyWith(filter: filtro);
  }

  void buscar(String texto) {
    state = state.copyWith(search: texto);
  }
}

// ============================================================
// Providers
// ============================================================

final medicalRecordsDataSourceProvider = Provider<MedicalRecordsDataSource>(
  (ref) => MedicalRecordsDataSource(),
);

final medicalRecordsRepositoryProvider = Provider<MedicalRecordsRepository>((
  ref,
) {
  return MedicalRecordsRepositoryImpl(
    ref.watch(medicalRecordsDataSourceProvider),
  );
});

final medicalRecordsControllerProvider =
    NotifierProvider<MedicalRecordsController, MedicalRecordsState>(
      MedicalRecordsController.new,
    );
