import '../../../home/data/dtos/financial_summary_dto.dart';
import '../dtos/appointment_history_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class HistoryDataSource {
  // Simula as chamadas de API com delay de 1 segundo e respostas em JSON.
  // A API já envia do mais recente para o mais antigo.

  Future<List<AppointmentHistoryDto>> buscarAtendimentos() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'date': '24 Out, 2025',
        'time': '14:30',
        'patient_name': 'Jorge Silva',
        'type': 'Avaliação',
        'professional_name': 'Lucas Meireles',
        'status': 'confirmed',
      },
      {
        'date': '12 Out, 2025',
        'time': '09:15',
        'patient_name': 'Antônio Marcos',
        'type': 'Saúde do Idoso',
        'professional_name': 'Lucas Meireles',
        'status': 'performed',
      },
      {
        'date': '28 Set, 2025',
        'time': '16:00',
        'patient_name': 'Carlos Eduardo',
        'type': 'Pediatria',
        'professional_name': 'Lucas Meireles',
        'status': 'performed',
      },
      {
        'date': '15 Set, 2025',
        'time': '11:30',
        'patient_name': 'Carlos Eduardo',
        'type': 'Pediatria',
        'professional_name': 'Lucas Meireles',
        'status': 'canceled',
      },
      {
        'date': '01 Ago, 2025',
        'time': '10:00',
        'patient_name': 'Maria Clara',
        'type': 'Pediatria',
        'professional_name': 'Beatriz Nogueira',
        'status': 'performed',
      },
      {
        'date': '18 Jul, 2025',
        'time': '08:30',
        'patient_name': 'Juliana Mendes',
        'type': 'Tratamento da Dor',
        'professional_name': 'Arnaldo Ribeiro',
        'status': 'performed',
      },
    ];

    return json.map(AppointmentHistoryDto.fromJson).toList();
  }

  Future<List<FinancialSummaryDto>> buscarLancamentos() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'date': '26 Out, 2025',
        'time': '14:30',
        'patient_name': 'Carlos Eduardo Silva',
        'type': 'Pediatria',
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
      {
        'date': '20 Out, 2025',
        'time': '10:00',
        'patient_name': 'Antônio Marcos',
        'type': 'Saúde do Idoso',
        'payment_method': 'Cartão de Débito',
        'amount': 600.00,
        'status': 'paid',
      },
      {
        'date': '18 Out, 2025',
        'time': '15:30',
        'patient_name': 'Jorge Silva',
        'type': 'Avaliação',
        'payment_method': 'PIX',
        'amount': 400.00,
        'status': 'pending',
      },
      {
        'date': '10 Out, 2025',
        'time': '08:45',
        'patient_name': 'Lucas Freitas',
        'type': 'Pediatria',
        'payment_method': 'Cartão de Crédito',
        'amount': 550.00,
        'status': 'paid',
      },
    ];

    return json.map(FinancialSummaryDto.fromJson).toList();
  }
}
