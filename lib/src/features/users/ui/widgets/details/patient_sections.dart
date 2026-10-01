import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/utils/moeda.dart';
import '../../../domain/models/consumption_model.dart';
import '../../../domain/models/contract_model.dart';
import '../../../domain/models/session_summary_model.dart';
import 'details_section.dart';

/// "CONTRATO DE SERVIÇOS": pacote, vigência, status e arquivo do contrato.
class ContractSection extends StatelessWidget {
  final ContractModel contract;

  const ContractSection({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'CONTRATO DE SERVIÇOS',
      child: DetailsPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Contrato: ',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  TextSpan(
                    text: contract.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DetailsInfo.texto(
                    rotulo: 'Início',
                    valor: contract.startDate,
                  ),
                ),
                Expanded(
                  child: DetailsInfo.texto(
                    rotulo: 'Validade',
                    valor: contract.endDate,
                  ),
                ),
                Expanded(
                  child: DetailsInfo(
                    rotulo: 'Status',
                    valor: DetailsStatusTag(
                      texto: contract.active ? 'Ativo' : 'Vencido',
                      positivo: contract.active,
                    ),
                  ),
                ),
              ],
            ),
            if (contract.fileName != null) ...[
              const SizedBox(height: 16),
              _ArquivoContrato(nome: contract.fileName!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArquivoContrato extends StatelessWidget {
  final String nome;

  const _ArquivoContrato({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DetailsIconBox(icon: Symbols.description),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Disponível para download',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: null,
          icon: Icon(
            Symbols.download,
            size: 18,
            color: AppColors.textActionButton,
          ),
          label: Text(
            'Baixar',
            style: TextStyle(color: AppColors.textActionButton),
          ),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.actionCardBackground,
            disabledBackgroundColor: AppColors.actionCardBackground.withValues(
              alpha: 0.6,
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

/// "RESUMO DAS SESSÕES RECENTES".
class RecentSessionsSection extends StatelessWidget {
  final List<SessionSummaryModel> sessions;

  const RecentSessionsSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'RESUMO DAS SESSÕES RECENTES',
      child: Column(
        children: [
          for (final sessao in sessions)
            DetailsListItem(
              icon: Symbols.calendar_today,
              titulo: sessao.title,
              data: sessao.date,
              destaque: sessao.note,
            ),
        ],
      ),
    );
  }
}

/// "RESUMO FINANCEIRO E CONSUMO": sessões contratadas/realizadas/disponíveis,
/// progresso e valores.
class ConsumptionSection extends StatelessWidget {
  final ConsumptionModel consumption;

  const ConsumptionSection({super.key, required this.consumption});

  static const _estiloNumero = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final porcentagem = (consumption.progress * 100).round();

    return DetailsSection(
      titulo: 'RESUMO FINANCEIRO E CONSUMO',
      child: DetailsPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DetailsInfo(
                    rotulo: 'Contratadas',
                    valor: Text(
                      '${consumption.contracted}',
                      style: _estiloNumero.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DetailsInfo(
                    rotulo: 'Realizadas',
                    valor: Text(
                      '${consumption.performed}',
                      style: _estiloNumero.copyWith(
                        color: AppColors.borderAccent,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DetailsInfo(
                    rotulo: 'Disponíveis',
                    valor: Text(
                      '${consumption.available}',
                      style: _estiloNumero.copyWith(
                        color: AppColors.borderAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Progresso do tratamento',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${consumption.performed} / ${consumption.contracted} ($porcentagem%)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.borderAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: consumption.progress,
                minHeight: 8,
                color: AppColors.borderAccent,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 12),
            DetailsRow(
              rotulo: 'Valor por sessão',
              valor: Moeda.formatar(consumption.sessionValue),
              corValor: AppColors.primary,
            ),
            DetailsRow(
              rotulo: 'Valor total do pacote',
              valor: Moeda.formatar(consumption.totalValue),
              corValor: AppColors.primary,
            ),
            if (consumption.paymentMethod != null)
              DetailsRow(
                rotulo: 'Forma de pagamento',
                valor: consumption.paymentMethod!,
              ),
          ],
        ),
      ),
    );
  }
}
