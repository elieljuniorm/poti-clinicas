import 'package:flutter/material.dart';

import '../../utils/moeda.dart';
import '../theme/app_colors.dart';

/// Card escuro de totais financeiros: valor principal em destaque e,
/// abaixo da linha, recebido e pendente.
///
/// Ex.: "TOTAL A RECEBER" (Histórico), "FATURAMENTO DO MÊS" (Financeiro).
class AppFinancialSummaryCard extends StatelessWidget {
  final String titulo;
  final double total;
  final double recebido;
  final double pendente;

  const AppFinancialSummaryCard({
    super.key,
    required this.titulo,
    required this.total,
    required this.recebido,
    required this.pendente,
  });

  static const _rotulo = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.summaryCardMuted,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.summaryCardBackground,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: _rotulo.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Moeda.formatar(total),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.summaryCardForeground,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _Valor(rotulo: 'RECEBIDO', valor: recebido),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Valor(rotulo: 'PENDENTE', valor: pendente),
              ),
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

class _Valor extends StatelessWidget {
  final String rotulo;
  final double valor;

  const _Valor({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: AppFinancialSummaryCard._rotulo),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Moeda.formatar(valor),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.summaryCardForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
