import '../../domain/models/daily_appointment_model.dart';
import '../../domain/models/evolution_model.dart';
import '../../domain/models/financial_summary_model.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  
  final List<DailyAppointmentModel> dailyAppointments;
  final List<EvolutionModel> evolutions;
  final List<FinancialSummaryModel> financialSummaries;

  HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.dailyAppointments = const [],
    this.evolutions = const [],
    this.financialSummaries = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DailyAppointmentModel>? dailyAppointments,
    List<EvolutionModel>? evolutions,
    List<FinancialSummaryModel>? financialSummaries,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      dailyAppointments: dailyAppointments ?? this.dailyAppointments,
      evolutions: evolutions ?? this.evolutions,
      financialSummaries: financialSummaries ?? this.financialSummaries,
    );
  }
}