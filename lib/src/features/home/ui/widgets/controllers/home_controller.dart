import 'package:flutter_riverpod/legacy.dart';
import '../../../domain/models/daily_appointment_model.dart';
import '../../../domain/models/evolution_model.dart';
import '../../../domain/models/financial_summary_model.dart';
import '../../states/home_state.dart';

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(HomeState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Daily Appointments
      final dailyAppointments = [
        DailyAppointmentModel(patient: 'Jorge Silva', time: '13:30', appointmentType: 'Avaliação', status: AppointmentStatus.canceled),
        DailyAppointmentModel(patient: 'Jonas Santos', time: '15:00', appointmentType: 'Tratamento da dor', status: AppointmentStatus.pending),
        DailyAppointmentModel(patient: 'Antônio Araújo', time: '16:20', appointmentType: 'Neuromodulação', status: AppointmentStatus.confirmed),
        DailyAppointmentModel(patient: 'Lucas Freitas', time: '18:00', appointmentType: 'Pediatria', status: AppointmentStatus.confirmed),
        DailyAppointmentModel(patient: 'Hery Nunes', time: '19:30', appointmentType: 'Saúde do Idoso', status: AppointmentStatus.canceled),
      ];

      // MOCK: Evolutions
      final evolutions = [
        EvolutionModel(date: '13/02', time: '10:30', professional: 'Lucas Meireles', patient: 'Antonia Maria', appointmentType: 'Avaliação', status: EvolutionStatus.open),
        EvolutionModel(date: '13/02', time: '08:30', professional: 'Lucas Meireles', patient: 'Eduardo Marinho', appointmentType: 'Pediatria', status: EvolutionStatus.closed),
      ];

      // MOCK: Financial Summaries
      final financialSummaries = [
        FinancialSummaryModel(date: '26 Out, 2025', time: '14:30', patient: 'Carlos Eduardo Silva', appointmentType: 'Avaliação', paymentMethod: 'Dinheiro', amount: 350.00, status: PaymentStatus.paid),
        FinancialSummaryModel(date: '25 Out, 2025', time: '09:15', patient: 'Maria Clara Rezende', appointmentType: 'Pediatria', paymentMethod: 'Cartão de Crédito', amount: 150.00, status: PaymentStatus.paid),
        FinancialSummaryModel(date: '25 Out, 2025', time: '16:00', patient: 'João Pedro Santos', appointmentType: 'Saúde do Idoso', paymentMethod: 'PIX', amount: 400.00, status: PaymentStatus.pending),
      ];

      state = state.copyWith(
        isLoading: false,
        dailyAppointments: dailyAppointments,
        evolutions: evolutions,
        financialSummaries: financialSummaries,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao carregar dados: $e');
    }
  }
}