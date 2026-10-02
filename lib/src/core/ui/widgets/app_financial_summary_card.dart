import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/utils/moeda.dart';
import '../../domain/models/financial_overview_model.dart';

/// Card escuro "TOTAL A RECEBER", com recebido e pendente abaixo.
class FinancialOverviewCard extends StatelessWidget {
  final FinancialOverviewModel overview;

  const FinancialOverviewCard({super.key, required this.overview});

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
          Text('TOTAL A RECEBER', style: _rotulo.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Moeda.formatar(overview.total),
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
                child: _Valor(rotulo: 'RECEBIDO', valor: overview.received),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Valor(rotulo: 'PENDENTE', valor: overview.pending),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          Text(rotulo, style: FinancialOverviewCard._rotulo),
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
