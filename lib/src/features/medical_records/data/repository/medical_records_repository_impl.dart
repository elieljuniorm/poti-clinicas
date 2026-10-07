import '../../domain/models/discharge_model.dart';
import '../../domain/models/evolution_model.dart';
import '../../domain/models/medical_record_content.dart';
import '../../domain/models/medical_record_create_model.dart';
import '../../domain/models/medical_record_details_model.dart';
import '../../domain/models/medical_record_summary_model.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../data_sources/medical_records_remote_data_source.dart';
import '../dtos/evolution_dto.dart';
import '../dtos/medical_record_content_dto.dart';
import '../dtos/medical_record_details_dto.dart';

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

  @override
  Future<MedicalRecordDetailsModel> buscarProntuario(String patientId) async {
    final dto = await _dataSource.buscarProntuario(patientId);
    return dto.toDomain();
  }

  @override
  Future<MedicalRecordDetailsModel> criarProntuario(
    String patientId,
    MedicalRecordCreateModel prontuario,
  ) async {
    final dto = await _dataSource.criarProntuario(
      patientId,
      MedicalRecordDetailsDto.createJson(prontuario),
    );
    return dto.toDomain();
  }

  @override
  Future<MedicalRecordDetailsModel> atualizarProntuario(
    String patientId,
    MedicalRecordContent anamnese,
  ) async {
    final dto = await _dataSource.atualizarProntuario(
      patientId,
      MedicalRecordContentDto.fromDomain(anamnese).toJson(),
    );
    return dto.toDomain();
  }

  @override
  Future<MedicalRecordDetailsModel> registrarEvolucao(
    String patientId,
    EvolutionCreateModel evolucao,
  ) async {
    final dto = await _dataSource.registrarEvolucao(
      patientId,
      EvolutionDto.createJson(evolucao),
    );
    return dto.toDomain();
  }

  @override
  Future<MedicalRecordDetailsModel> registrarAlta(
    String patientId, {
    required DischargeReason motivo,
    required String descricao,
  }) async {
    final dto = await _dataSource.registrarAlta(
      patientId,
      MedicalRecordDetailsDto.dischargeJson(motivo, descricao),
    );
    return dto.toDomain();
  }
}
