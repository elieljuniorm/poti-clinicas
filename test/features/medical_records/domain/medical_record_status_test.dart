import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_filter.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_status.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_summary_model.dart';

final agora = DateTime(2026, 10, 6, 12);
final sessao = agora.subtract(const Duration(days: 3));

MedicalRecordStatus status({
  DateTime? lastSession,
  bool semSessao = false,
  bool hasRecord = true,
  DateTime? pendingEvolutionSince,
  bool discharged = false,
}) {
  return MedicalRecordSummaryModel(
    patientId: '1',
    patientName: 'Paciente',
    specialty: 'Fisioterapia',
    lastSession: semSessao ? null : lastSession ?? sessao,
    hasRecord: hasRecord,
    pendingEvolutionSince: pendingEvolutionSince,
    discharged: discharged,
  ).statusEm(agora);
}

void main() {
  group('status do prontuário', () {
    test('nenhuma sessão realizada: Novo (com ou sem prontuário)', () {
      expect(
        status(semSessao: true, hasRecord: false),
        MedicalRecordStatus.newPatient,
      );
      expect(status(semSessao: true), MedicalRecordStatus.newPatient);
    });

    test('sessão realizada sem prontuário: Pendente, mesmo dentro de 24h', () {
      expect(status(hasRecord: false), MedicalRecordStatus.pending);
      expect(
        status(
          hasRecord: false,
          lastSession: agora.subtract(const Duration(hours: 1)),
        ),
        MedicalRecordStatus.pending,
      );
    });

    test('prontuário e evoluções em dia: Em Terapia', () {
      expect(status(), MedicalRecordStatus.inTherapy);
    });

    test('sessão sem evolução há mais de 24h: Pendente', () {
      expect(
        status(pendingEvolutionSince: sessao),
        MedicalRecordStatus.pending,
      );
      expect(
        status(
          pendingEvolutionSince: agora.subtract(
            const Duration(hours: 24, minutes: 1),
          ),
        ),
        MedicalRecordStatus.pending,
      );
    });

    test('sessão sem evolução dentro das 24h: continua Em Terapia', () {
      final recente = agora.subtract(const Duration(hours: 23));
      expect(
        status(lastSession: recente, pendingEvolutionSince: recente),
        MedicalRecordStatus.inTherapy,
      );
      // Exatamente 24h ainda está no prazo.
      final limite = agora.subtract(MedicalRecordSummaryModel.prazoEvolucao);
      expect(
        status(lastSession: limite, pendingEvolutionSince: limite),
        MedicalRecordStatus.inTherapy,
      );
    });

    test('vale a sessão mais antiga sem evolução, não a última', () {
      // Última sessão há 2h, mas uma de 3 dias atrás ficou sem evolução.
      expect(
        status(
          lastSession: agora.subtract(const Duration(hours: 2)),
          pendingEvolutionSince: sessao,
        ),
        MedicalRecordStatus.pending,
      );
    });

    test('prontuário fechado: Alta Médica, mesmo com pendência', () {
      expect(status(discharged: true), MedicalRecordStatus.discharged);
      expect(
        status(discharged: true, pendingEvolutionSince: sessao),
        MedicalRecordStatus.discharged,
      );
    });
  });

  test('filtro "Todos" aceita qualquer status; os outros, só o seu', () {
    for (final s in MedicalRecordStatus.values) {
      expect(MedicalRecordFilter.all.aceita(s), isTrue);
    }
    expect(
      MedicalRecordFilter.discharged.aceita(MedicalRecordStatus.discharged),
      isTrue,
    );
    expect(
      MedicalRecordFilter.discharged.aceita(MedicalRecordStatus.inTherapy),
      isFalse,
    );
  });
}
