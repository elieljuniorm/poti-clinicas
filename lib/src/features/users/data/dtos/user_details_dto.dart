import '../../domain/models/access_info_model.dart';
import '../../domain/models/consumption_model.dart';
import '../../domain/models/contract_model.dart';
import '../../domain/models/month_summary_model.dart';
import '../../domain/models/professional_info_model.dart';
import '../../domain/models/session_summary_model.dart';
import '../../domain/models/upcoming_appointment_model.dart';
import '../../domain/models/user_details_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
/// Cada bloco é opcional: a API só envia os que se aplicam ao perfil.
class UserDetailsDto {
  final Map<String, dynamic>? contract;
  final List<Map<String, dynamic>> recentSessions;
  final Map<String, dynamic>? consumption;
  final Map<String, dynamic>? professionalInfo;
  final List<Map<String, dynamic>> upcomingAppointments;
  final Map<String, dynamic>? monthSummary;
  final Map<String, dynamic>? accessInfo;

  UserDetailsDto({
    this.contract,
    this.recentSessions = const [],
    this.consumption,
    this.professionalInfo,
    this.upcomingAppointments = const [],
    this.monthSummary,
    this.accessInfo,
  });

  static List<Map<String, dynamic>> _lista(dynamic json) {
    return (json as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // JSON → DTO
  factory UserDetailsDto.fromJson(Map<String, dynamic> json) {
    return UserDetailsDto(
      contract: json['contract'],
      recentSessions: _lista(json['recent_sessions']),
      consumption: json['consumption'],
      professionalInfo: json['professional_info'],
      upcomingAppointments: _lista(json['upcoming_appointments']),
      monthSummary: json['month_summary'],
      accessInfo: json['access_info'],
    );
  }

  // DTO → Model de domínio
  UserDetailsModel toDomain() {
    final contract = this.contract;
    final consumption = this.consumption;
    final professionalInfo = this.professionalInfo;
    final monthSummary = this.monthSummary;
    final accessInfo = this.accessInfo;

    return UserDetailsModel(
      contract: contract == null
          ? null
          : ContractModel(
              name: contract['name'],
              startDate: contract['start_date'],
              endDate: contract['end_date'],
              active: contract['status'] == 'active',
              fileName: contract['file_name'],
            ),
      recentSessions: recentSessions
          .map(
            (json) => SessionSummaryModel(
              title: json['title'],
              date: json['date'],
              note: json['note'],
            ),
          )
          .toList(),
      consumption: consumption == null
          ? null
          : ConsumptionModel(
              contracted: consumption['contracted'],
              performed: consumption['performed'],
              sessionValue: (consumption['session_value'] as num).toDouble(),
              paymentMethod: consumption['payment_method'],
            ),
      professionalInfo: professionalInfo == null
          ? null
          : ProfessionalInfoModel(
              specialty: professionalInfo['specialty'],
              registry: professionalInfo['registry'],
              bond: professionalInfo['bond'],
              since: professionalInfo['since'],
            ),
      upcomingAppointments: upcomingAppointments
          .map(
            (json) => UpcomingAppointmentModel(
              date: json['date'],
              time: json['time'],
              patient: json['patient_name'],
              appointmentType: json['type'],
            ),
          )
          .toList(),
      monthSummary: monthSummary == null
          ? null
          : MonthSummaryModel(
              performed: monthSummary['performed'],
              scheduled: monthSummary['scheduled'],
              activePatients: monthSummary['active_patients'],
            ),
      accessInfo: accessInfo == null
          ? null
          : AccessInfoModel(
              area: accessInfo['area'],
              since: accessInfo['since'],
              lastAccess: accessInfo['last_access'],
            ),
    );
  }
}
