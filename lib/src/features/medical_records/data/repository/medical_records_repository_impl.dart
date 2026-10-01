import '../../domain/models/medical_record_summary_model.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../data_sources/medical_records_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Converte DTO → model. O domínio não conhece DTO.
class MedicalRecordsRepositoryImpl implements MedicalRecordsRepository {
  final MedicalRecordsDataSource _dataSource;

  MedicalRecordsRepositoryImpl(this._dataSource);

  @override
  Future<List<MedicalRecordSummaryModel>> buscarProntuarios() async {
    final dtos = await _dataSource.buscarProntuarios();
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
