import 'access_info_model.dart';
import 'consumption_model.dart';
import 'contract_model.dart';
import 'month_summary_model.dart';
import 'professional_info_model.dart';
import 'session_summary_model.dart';
import 'upcoming_appointment_model.dart';

/// Detalhes exibidos no modal do usuário.
///
/// Cada campo é uma seção do modal e só aparece quando vier preenchido,
/// assim cada perfil mostra o que faz sentido para ele:
/// - Paciente: [contract], [recentSessions], [consumption].
/// - Profissional: [professionalInfo], [upcomingAppointments], [monthSummary].
/// - Administrador, recepção e colaborador: [accessInfo].
class UserDetailsModel {
  final ContractModel? contract;
  final List<SessionSummaryModel> recentSessions;
  final ConsumptionModel? consumption;

  final ProfessionalInfoModel? professionalInfo;
  final List<UpcomingAppointmentModel> upcomingAppointments;
  final MonthSummaryModel? monthSummary;

  final AccessInfoModel? accessInfo;

  const UserDetailsModel({
    this.contract,
    this.recentSessions = const [],
    this.consumption,
    this.professionalInfo,
    this.upcomingAppointments = const [],
    this.monthSummary,
    this.accessInfo,
  });

  bool get isEmpty =>
      contract == null &&
      recentSessions.isEmpty &&
      consumption == null &&
      professionalInfo == null &&
      upcomingAppointments.isEmpty &&
      monthSummary == null &&
      accessInfo == null;
}
