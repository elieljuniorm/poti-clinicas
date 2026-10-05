import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/utils/datas.dart';
import '../../states/new_appointment_draft.dart';
import 'remove_circle_button.dart';

/// Linha de uma data escolhida: dia, horário de início e de fim, remover.
class SessionTile extends StatelessWidget {
  final SessionDraft sessao;
  final VoidCallback aoEscolherInicio;
  final VoidCallback aoEscolherFim;
  final VoidCallback aoRemover;
  final String? erro;
  final bool habilitado;

  const SessionTile({
    super.key,
    required this.sessao,
    required this.aoEscolherInicio,
    required this.aoEscolherFim,
    required this.aoRemover,
    this.erro,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final temErro = erro != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
            decoration: AppDecorations.card,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.borderAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  Datas.data(sessao.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Horario(
                    dica: 'Início',
                    horario: sessao.start,
                    erro: temErro && sessao.start == null,
                    onTap: habilitado ? aoEscolherInicio : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Horario(
                    dica: 'Fim',
                    horario: sessao.end,
                    erro: temErro && (sessao.end == null || sessao.preenchida),
                    onTap: habilitado ? aoEscolherFim : null,
                  ),
                ),
                RemoveCircleButton(
                  dica: 'Remover data',
                  onTap: habilitado ? aoRemover : null,
                ),
              ],
            ),
          ),
          if (temErro)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                erro!,
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Pílula cinza com o horário (ou a dica) e o ícone de relógio.
class _Horario extends StatelessWidget {
  final String dica;
  final TimeOfDay? horario;
  final bool erro;
  final VoidCallback? onTap;

  const _Horario({
    required this.dica,
    required this.horario,
    required this.erro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final horario = this.horario;
    final texto = horario == null
        ? dica
        : Datas.hora(horario.hour, horario.minute);

    return Semantics(
      button: true,
      label: '$dica: ${horario == null ? 'não definido' : texto}',
      // excludeSemantics esconde o toque do InkWell: repassa aqui.
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceMuted,
        shape: StadiumBorder(
          side: erro
              ? const BorderSide(color: AppColors.error)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: horario == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                      color: horario == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Symbols.schedule,
                  size: 18,
                  color: AppColors.borderAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
