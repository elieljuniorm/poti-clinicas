import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';

/// Legenda dos status de atendimento: Confirmado, Pendente e Cancelado.
/// Usada acima das tabelas de atendimentos (Home, Agenda).
class AppStatusLegend extends StatelessWidget {
  const AppStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      // Wrap: em telas estreitas os itens quebram de linha em vez de estourar.
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          _ItemLegenda(
            icon: Symbols.check_circle,
            texto: 'Confirmado',
            cor: AppColors.statusConfirmed,
          ),
          _ItemLegenda(
            icon: Symbols.circle,
            texto: 'Pendente',
            cor: AppColors.statusPending,
          ),
          _ItemLegenda(
            icon: Symbols.cancel,
            texto: 'Cancelado',
            cor: AppColors.statusCanceled,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _ItemLegenda extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color cor;

  const _ItemLegenda({
    required this.icon,
    required this.texto,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: cor, size: 18),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
