import '../../domain/models/scheduling_appointment_model.dart';
import '../../domain/models/scheduling_period.dart';

class SchedulingState {
  final bool isLoading;
  final String? errorMessage;

  /// Período selecionado no filtro (Dia / Semana / Mês).
  final SchedulingPeriod period;
  final List<SchedulingAppointmentModel> appointments;

  const SchedulingState({
    this.isLoading = false,
    this.errorMessage,
    this.period = SchedulingPeriod.day,
    this.appointments = const [],
  });

  SchedulingState copyWith({
    bool? isLoading,
    String? errorMessage,
    SchedulingPeriod? period,
    List<SchedulingAppointmentModel>? appointments,
  }) {
    return SchedulingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      period: period ?? this.period,
      appointments: appointments ?? this.appointments,
    );
  }
}
