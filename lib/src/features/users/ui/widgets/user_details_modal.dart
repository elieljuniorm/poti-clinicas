import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_avatar.dart';
import '../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../application/user_details_controller.dart';
import '../../domain/models/user_details_model.dart';
import '../../domain/models/user_model.dart';
import 'details/access_info_section.dart';
import 'details/patient_sections.dart';
import 'details/professional_sections.dart';

/// Abre o modal com os dados do [user] (padrão de [showAppModalSheet]).
Future<void> showUserDetailsModal(BuildContext context, UserModel user) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => UserDetailsModal(user: user),
  );
}

class UserDetailsModal extends ConsumerWidget {
  final UserModel user;

  const UserDetailsModal({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(userDetailsControllerProvider(user.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Área fixa (não rola): arrastar aqui fecha o modal.
        const AppSheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: _CabecalhoUsuario(user: user),
        ),
        // Conteúdo com scroll interno; o modal cresce até a altura máxima.
        Flexible(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              child: detailsState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : detailsState.errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        detailsState.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _Secoes(user: user, details: detailsState.details!),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Card do topo com foto, nome e contatos do usuário.
class _CabecalhoUsuario extends StatelessWidget {
  final UserModel user;

  const _CabecalhoUsuario({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.actionCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderAccent),
      ),
      child: Row(
        children: [
          AppAvatar(fotoUrl: user.photoUrl, raio: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                _Contato(icon: Symbols.mail, texto: user.email),
                const SizedBox(height: 2),
                _Contato(icon: Symbols.call, texto: user.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Contato extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Contato({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.borderAccent),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Monta as seções que vieram preenchidas para o usuário.
class _Secoes extends StatelessWidget {
  final UserModel user;
  final UserDetailsModel details;

  const _Secoes({required this.user, required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'Nenhuma informação adicional',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    final contract = details.contract;
    final consumption = details.consumption;
    final professionalInfo = details.professionalInfo;
    final monthSummary = details.monthSummary;
    final accessInfo = details.accessInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Paciente
        if (contract != null) ContractSection(contract: contract),
        if (details.recentSessions.isNotEmpty)
          RecentSessionsSection(sessions: details.recentSessions),
        if (consumption != null) ConsumptionSection(consumption: consumption),

        // Profissional
        if (professionalInfo != null)
          ProfessionalInfoSection(info: professionalInfo),
        if (details.upcomingAppointments.isNotEmpty)
          UpcomingAppointmentsSection(
            appointments: details.upcomingAppointments,
          ),
        if (monthSummary != null) MonthSummarySection(summary: monthSummary),

        // Administrador, recepção e colaborador
        if (accessInfo != null) AccessInfoSection(user: user, info: accessInfo),
      ],
    );
  }
}
