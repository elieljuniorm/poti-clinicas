import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../../../core/utils/moeda.dart';
import '../../domain/models/financial_summary_model.dart';

/// Card de um lançamento financeiro: data, status (Pago/Pendente),
/// forma de pagamento, paciente, atendimento e valor.
///
/// Usado no resumo da Home e no histórico de lançamentos.
class FinancialEntryCard extends StatelessWidget {
  final FinancialSummaryModel item;

  const FinancialEntryCard({super.key, required this.item});

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'Dinheiro':
        return Symbols.attach_money;
      case 'PIX':
        return Icons.pix_sharp;
      case 'Cartão de Crédito':
        return Symbols.credit_card;
      case 'Cartão de Débito':
        return Symbols.account_balance_wallet;
      default:
        return Symbols.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = item.status == PaymentStatus.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Symbols.calendar_today,
                    size: 16,
                    color: AppColors.borderAccent,
                  ),
                  const SizedBox(width: 8),
                  // Data em destaque e horário em cinza, como no card
                  // de atendimento do histórico.
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '  às ${item.time}',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? 'Pago' : 'Pendente',
                  style: TextStyle(
                    color: isPaid ? Colors.green[700] : Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPaymentIcon(item.paymentMethod),
                  color: AppColors.borderAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.patient,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${item.appointmentType} - ${item.paymentMethod}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                Moeda.formatar(item.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
