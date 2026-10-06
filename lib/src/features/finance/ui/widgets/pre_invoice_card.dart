import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../domain/models/pre_invoice_model.dart';

/// Card da pré-fatura: paciente, profissional e sessões a faturar.
/// Tocar abre o lançamento já preenchido para finalizar a fatura.
class PreInvoiceCard extends StatelessWidget {
  final PreInvoiceModel preInvoice;
  final VoidCallback onTap;

  const PreInvoiceCard({
    super.key,
    required this.preInvoice,
    required this.onTap,
  });

  static String sessoes(int total) =>
      total == 1 ? '1 sessão' : '$total sessões';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.actionCardBackground,
                  child: Icon(
                    Symbols.receipt_long,
                    color: AppColors.borderAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preInvoice.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preInvoice.professionalName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sessoes(preInvoice.sessions),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.borderAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.recordPendingBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'A FATURAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.recordPending,
                    ),
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
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
