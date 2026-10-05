import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../domain/models/scheduling_appointment_model.dart';

/// Card "STATUS DO AGENDAMENTO" com Confirmar / Cancelar / Pendente.
/// Os ícones e cores são os mesmos da legenda da Agenda.
class AppointmentStatusSelector extends StatelessWidget {
  final AppointmentStatus selecionado;
  final ValueChanged<AppointmentStatus> aoSelecionar;
  final bool habilitado;

  const AppointmentStatusSelector({
    super.key,
    required this.selecionado,
    required this.aoSelecionar,
    this.habilitado = true,
  });

  static const _opcoes = [
    (AppointmentStatus.confirmed, 'Confirmar', Symbols.check_circle),
    (AppointmentStatus.canceled, 'Cancelar', Symbols.cancel),
    (AppointmentStatus.pending, 'Pendente', Symbols.circle),
  ];

  static Color corDe(AppointmentStatus status) => switch (status) {
    AppointmentStatus.confirmed => AppColors.statusConfirmed,
    AppointmentStatus.canceled => AppColors.statusCanceled,
    AppointmentStatus.pending => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'STATUS DO AGENDAMENTO',
            style: AppTextStyles.detailsSectionTitle,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final (status, rotulo, icone) in _opcoes) ...[
                Expanded(
                  child: _Opcao(
                    rotulo: rotulo,
                    icone: icone,
                    cor: corDe(status),
                    ativo: status == selecionado,
                    onTap: habilitado ? () => aoSelecionar(status) : null,
                  ),
                ),
                if (status != _opcoes.last.$1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Opcao extends StatelessWidget {
  final String rotulo;
  final IconData icone;
  final Color cor;
  final bool ativo;
  final VoidCallback? onTap;

  const _Opcao({
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Todas com fundo claro na cor do status; a escolhida ganha borda e
    // texto em negrito.
    final forma = StadiumBorder(
      side: ativo ? BorderSide(color: cor, width: 1.5) : BorderSide.none,
    );

    return Semantics(
      button: true,
      selected: ativo,
      label: rotulo,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: cor.withValues(alpha: ativo ? 0.16 : 0.10),
        shape: forma,
        child: InkWell(
          onTap: onTap,
          customBorder: forma,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            // Em telas estreitas o conteúdo encolhe em vez de cortar o texto.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icone, size: 20, color: cor),
                  const SizedBox(width: 4),
                  Text(
                    rotulo,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: ativo ? FontWeight.bold : FontWeight.w600,
                      color: cor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
