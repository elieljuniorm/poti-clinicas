import 'package:flutter/material.dart';

import '../../domain/models/financial_summary_model.dart';

class FinancialSummaryWidget extends StatelessWidget {
  final List<FinancialSummaryModel> summaries;

  const FinancialSummaryWidget({super.key, required this.summaries});

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'Dinheiro':
        return Icons.attach_money;
      case 'PIX':
        return Icons.pix_sharp;
      case 'Cartão de Crédito':
        return Icons.credit_card;
      case 'Cartão de Débito':
        return Icons.credit_card_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = summaries[index];
        final isPaid = item.status == PaymentStatus.paid;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color.fromRGBO(25, 126, 144, 1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.date} às ${item.time}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
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
                      color: const Color.fromRGBO(242, 242, 247, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPaymentIcon(item.paymentMethod),
                      color: const Color.fromRGBO(25, 126, 144, 1),
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'R\$ ${item.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      color: Color(0xFF0F4C5C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
