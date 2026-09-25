import '../dtos/daily_appointment_dto.dart';
import '../dtos/evolution_dto.dart';
import '../dtos/financial_summary_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class HomeDataSource {
  // Simula as chamadas de API com delay de 1 segundo e respostas em JSON.

  Future<List<DailyAppointmentDto>> buscarAtendimentosDoDia() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'patient_name': 'Jorge Silva',
        'time': '13:30',
        'type': 'Avaliação',
        'status': 'canceled',
      },
      {
        'patient_name': 'Jonas Santos',
        'time': '15:00',
        'type': 'Tratamento da dor',
        'status': 'pending',
      },
      {
        'patient_name': 'Antônio Araújo',
        'time': '16:20',
        'type': 'Neuromodulação',
        'status': 'confirmed',
      },
      {
        'patient_name': 'Lucas Freitas',
        'time': '18:00',
        'type': 'Pediatria',
        'status': 'confirmed',
      },
      {
        'patient_name': 'Hery Nunes',
        'time': '19:30',
        'type': 'Saúde do Idoso',
        'status': 'canceled',
      },
    ];

    return json.map(DailyAppointmentDto.fromJson).toList();
  }

  Future<List<EvolutionDto>> buscarEvolucoes() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'date': '13/02',
        'time': '10:30',
        'professional_name': 'Lucas Meireles',
        'patient_name': 'Antonia Maria',
        'type': 'Avaliação',
        'status': 'open',
      },
      {
        'date': '13/02',
        'time': '08:30',
        'professional_name': 'Lucas Meireles',
        'patient_name': 'Eduardo Marinho',
        'type': 'Pediatria',
        'status': 'closed',
      },
    ];

    return json.map(EvolutionDto.fromJson).toList();
  }

  Future<List<FinancialSummaryDto>> buscarResumoFinanceiro() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'date': '26 Out, 2025',
        'time': '14:30',
        'patient_name': 'Carlos Eduardo Silva',
        'type': 'Avaliação',
        'payment_method': 'Dinheiro',
        'amount': 350.00,
        'status': 'paid',
      },
      {
        'date': '25 Out, 2025',
        'time': '09:15',
        'patient_name': 'Maria Clara Rezende',
        'type': 'Pediatria',
        'payment_method': 'Cartão de Crédito',
        'amount': 150.00,
        'status': 'paid',
      },
      {
        'date': '25 Out, 2025',
        'time': '16:00',
        'patient_name': 'João Pedro Santos',
        'type': 'Saúde do Idoso',
        'payment_method': 'PIX',
        'amount': 400.00,
        'status': 'pending',
      },
    ];

    return json.map(FinancialSummaryDto.fromJson).toList();
  }
}
