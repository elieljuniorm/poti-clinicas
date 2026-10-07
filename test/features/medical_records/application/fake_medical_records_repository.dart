import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_content.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/discharge_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/evolution_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_create_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_details_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_summary_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/repositories/medical_records_repository.dart';

class FakeMedicalRecordsRepository implements MedicalRecordsRepository {
  bool deveFalhar;
  String? erroSalvar;
  final List<MedicalRecordCreateModel> criados = [];
  final List<MedicalRecordContent> edicoes = [];

  /// Pacientes da lista. Padrão: [padrao].
  final List<MedicalRecordSummaryModel> prontuarios;

  FakeMedicalRecordsRepository({
    this.deveFalhar = false,
    this.erroSalvar,
    List<MedicalRecordSummaryModel>? prontuarios,
  }) : prontuarios = prontuarios ?? padrao;

  static final criacao = DateTime(_ano, 1, 10, 9);

  // Ano corrente: a data aparece sem o ano ("12/02, 13:30") em qualquer ano.
  static final _ano = DateTime.now().year;

  static final padrao = [
    MedicalRecordSummaryModel(
      patientId: '1',
      patientName: 'Jorge Silva',
      specialty: 'Fisioterapia',
      lastSession: DateTime(_ano, 2, 12, 13, 30),
      hasRecord: true,
    ),
    const MedicalRecordSummaryModel(
      patientId: '2',
      patientName: 'Antônio Araújo',
      specialty: 'Fisioterapia',
    ),
    MedicalRecordSummaryModel(
      patientId: '3',
      patientName: 'Lucas Freitas',
      specialty: 'Terapia Ocupacional',
      lastSession: DateTime(_ano, 2, 8, 18),
      hasRecord: true,
      pendingEvolutionSince: DateTime(_ano, 2, 8, 18),
    ),
    MedicalRecordSummaryModel(
      patientId: '4',
      patientName: 'Helena Costa',
      specialty: 'Fisioterapia',
      lastSession: DateTime(_ano, 1, 20, 10),
      hasRecord: true,
      discharged: true,
    ),
  ];

  @override
  Future<List<MedicalRecordSummaryModel>> buscarProntuarios() async {
    if (deveFalhar) throw Exception('sem conexão');
    return [for (final p in prontuarios) _resumo(p.patientId)];
  }

  /// Prontuários já criados (os da lista com `hasRecord`), por paciente.
  late final Map<String, MedicalRecordModel> _registros = {
    for (final p in prontuarios)
      if (p.hasRecord)
        p.patientId: MedicalRecordModel(
          content: const MedicalRecordContent({
            MedicalRecordField.chiefComplaint: 'Dor lombar.',
            MedicalRecordField.medicalDiagnosis: 'Hérnia de disco L4-L5.',
          }),
          createdAt: criacao,
          updatedAt: criacao,
        ),
  };
  final Map<String, EvolutionModel> _evolucoes = {};
  final List<EvolutionCreateModel> evolucoesRegistradas = [];
  final Map<String, DischargeModel> altas = {};

  /// Resumo atual: criar o prontuário (e a evolução) muda o status.
  MedicalRecordSummaryModel _resumo(String patientId) {
    final p = prontuarios.firstWhere((p) => p.patientId == patientId);
    return MedicalRecordSummaryModel(
      patientId: p.patientId,
      patientName: p.patientName,
      specialty: p.specialty,
      lastSession: p.lastSession,
      hasRecord: _registros.containsKey(patientId),
      pendingEvolutionSince: _evolucoes.containsKey(patientId)
          ? null
          : p.pendingEvolutionSince,
      discharged: p.discharged || altas.containsKey(patientId),
    );
  }

  MedicalRecordDetailsModel _detalhes(String patientId) {
    return MedicalRecordDetailsModel(
      summary: _resumo(patientId),
      email: 'paciente$patientId@email.com',
      professionalName: 'Arnaldo Ribeiro',
      sessionCount: _resumo(patientId).lastSession == null ? 0 : 3,
      record: _registros[patientId],
      latestEvolution: _evolucoes[patientId],
      discharge: altas[patientId],
    );
  }

  @override
  Future<MedicalRecordDetailsModel> buscarProntuario(String patientId) async {
    if (deveFalhar) throw Exception('sem conexão');
    return _detalhes(patientId);
  }

  @override
  Future<MedicalRecordDetailsModel> criarProntuario(
    String patientId,
    MedicalRecordCreateModel prontuario,
  ) async {
    final erro = erroSalvar;
    if (erro != null) throw Exception(erro);
    criados.add(prontuario);
    _registros[patientId] = MedicalRecordModel(
      content: prontuario.content,
      createdAt: criacao,
      updatedAt: criacao,
    );
    final evolucao = prontuario.evolution;
    if (evolucao != null) _salvarEvolucao(patientId, evolucao);
    return _detalhes(patientId);
  }

  @override
  Future<MedicalRecordDetailsModel> atualizarProntuario(
    String patientId,
    MedicalRecordContent anamnese,
  ) async {
    final erro = erroSalvar;
    if (erro != null) throw Exception(erro);
    edicoes.add(anamnese);
    _registros[patientId] = MedicalRecordModel(
      content: anamnese,
      createdAt: criacao,
      updatedAt: DateTime(_ano, 2, 20, 10, 15),
    );
    return _detalhes(patientId);
  }

  @override
  Future<MedicalRecordDetailsModel> registrarAlta(
    String patientId, {
    required DischargeReason motivo,
    required String descricao,
  }) async {
    final erro = erroSalvar;
    if (erro != null) throw Exception(erro);
    altas[patientId] = DischargeModel(
      reason: motivo,
      description: descricao,
      date: DateTime(_ano, 3, 1, 10),
      professionalName: 'Arnaldo Ribeiro',
    );
    return _detalhes(patientId);
  }

  @override
  Future<MedicalRecordDetailsModel> registrarEvolucao(
    String patientId,
    EvolutionCreateModel evolucao,
  ) async {
    final erro = erroSalvar;
    if (erro != null) throw Exception(erro);
    evolucoesRegistradas.add(evolucao);
    _salvarEvolucao(patientId, evolucao);
    return _detalhes(patientId);
  }

  void _salvarEvolucao(String patientId, EvolutionCreateModel evolucao) {
    _evolucoes[patientId] = EvolutionModel(
      sessionNumber: evolucao.sessionNumber,
      sessionDate: evolucao.sessionDate,
      professionalName: 'Arnaldo Ribeiro',
      description: evolucao.description,
      observations: evolucao.observations,
      clinicalProgress: evolucao.clinicalProgress,
      patientStatus: evolucao.patientStatus,
      scale: evolucao.scale,
      registeredBy: 'Fernanda Lima',
      registeredAt: DateTime(_ano, 3, 2, 18),
    );
  }
}
