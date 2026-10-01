import '../../../../core/utils/texto.dart';
import '../../domain/models/medical_record_filter.dart';
import '../../domain/models/medical_record_summary_model.dart';

class MedicalRecordsState {
  final bool isLoading;
  final String? errorMessage;

  /// Todos os pacientes carregados (sem filtro).
  final List<MedicalRecordSummaryModel> records;

  /// Chip selecionado (Todos / Em Terapia / Novo / Pendente / Alta Médica).
  final MedicalRecordFilter filter;

  /// Texto digitado na busca (nome do paciente).
  final String search;

  const MedicalRecordsState({
    this.isLoading = false,
    this.errorMessage,
    this.records = const [],
    this.filter = MedicalRecordFilter.all,
    this.search = '',
  });

  /// Pacientes exibidos: aplica o filtro e a busca (sem diferenciar acentos).
  List<MedicalRecordSummaryModel> get filteredRecords {
    return records
        .where(
          (record) =>
              filter.aceita(record.status) &&
              Texto.contem(record.patientName, search),
        )
        .toList();
  }

  MedicalRecordsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MedicalRecordSummaryModel>? records,
    MedicalRecordFilter? filter,
    String? search,
  }) {
    return MedicalRecordsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      records: records ?? this.records,
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}
