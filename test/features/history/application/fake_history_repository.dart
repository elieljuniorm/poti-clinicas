import 'package:multiclinica_app/src/features/history/domain/models/appointment_history_model.dart';
import 'package:multiclinica_app/src/features/history/domain/models/appointment_history_status.dart';
import 'package:multiclinica_app/src/features/history/domain/repositories/history_repository.dart';
import 'package:multiclinica_app/src/features/home/domain/models/financial_summary_model.dart';

class FakeHistoryRepository implements HistoryRepository {
  bool deveFalhar;
  int quantidadeLancamentos;

  FakeHistoryRepository({
    this.deveFalhar = false,
    this.quantidadeLancamentos = 5,
  });

  @override
  Future<List<AppointmentHistoryModel>> buscarAtendimentos() async {
    if (deveFalhar) throw Exception('sem conexão');
    return const [
      AppointmentHistoryModel(
        date: '24 Out, 2025',
        time: '14:30',
        patient: 'Jorge Silva',
        appointmentType: 'Avaliação',
        professional: 'Lucas Meireles',
        status: AppointmentHistoryStatus.confirmed,
      ),
      AppointmentHistoryModel(
        date: '15 Set, 2025',
        time: '11:30',
        patient: 'Carlos Eduardo',
        appointmentType: 'Pediatria',
        professional: 'Lucas Meireles',
        status: AppointmentHistoryStatus.canceled,
      ),
    ];
  }

  @override
  Future<List<FinancialSummaryModel>> buscarLancamentos() async {
    return [
      for (var i = 1; i <= quantidadeLancamentos; i++)
        FinancialSummaryModel(
          date: '$i Out, 2025',
          time: '10:00',
          patient: 'Paciente $i',
          appointmentType: 'Pediatria',
          paymentMethod: 'PIX',
          amount: 100,
          status: i.isEven ? PaymentStatus.pending : PaymentStatus.paid,
        ),
    ];
  }
}
