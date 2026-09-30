import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../domain/models/month_summary_model.dart';
import '../../../domain/models/professional_info_model.dart';
import '../../../domain/models/upcoming_appointment_model.dart';
import 'details_section.dart';

/// "DADOS PROFISSIONAIS": especialidade, registro, vínculo e data de início.
class ProfessionalInfoSection extends StatelessWidget {
  final ProfessionalInfoModel info;

  const ProfessionalInfoSection({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'DADOS PROFISSIONAIS',
      child: DetailsPanel(
        child: Column(
          children: [
            DetailsRow(rotulo: 'Especialidade', valor: info.specialty),
            DetailsRow(rotulo: 'Registro', valor: info.registry),
            DetailsRow(rotulo: 'Vínculo', valor: info.bond),
            DetailsRow(rotulo: 'Na clínica desde', valor: info.since),
          ],
        ),
      ),
    );
  }
}

/// "PRÓXIMOS ATENDIMENTOS" do profissional.
class UpcomingAppointmentsSection extends StatelessWidget {
  final List<UpcomingAppointmentModel> appointments;

  const UpcomingAppointmentsSection({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'PRÓXIMOS ATENDIMENTOS',
      child: Column(
        children: [
          for (final atendimento in appointments)
            DetailsListItem(
              icon: Symbols.calendar_clock,
              titulo: atendimento.patient,
              data: '${atendimento.date} às ${atendimento.time}',
              destaque: atendimento.appointmentType,
            ),
        ],
      ),
    );
  }
}

/// "RESUMO DO MÊS": atendimentos realizados, agendados e pacientes ativos.
class MonthSummarySection extends StatelessWidget {
  final MonthSummaryModel summary;

  const MonthSummarySection({super.key, required this.summary});

  Widget _numero(String rotulo, int valor, Color cor) {
    return Expanded(
      child: DetailsInfo(
        rotulo: rotulo,
        valor: Text(
          '$valor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'RESUMO DO MÊS',
      child: DetailsPanel(
        child: Row(
          children: [
            _numero('Realizados', summary.performed, AppColors.textPrimary),
            _numero('Agendados', summary.scheduled, AppColors.borderAccent),
            _numero(
              'Pacientes',
              summary.activePatients,
              AppColors.borderAccent,
            ),
          ],
        ),
      ),
    );
  }
}
