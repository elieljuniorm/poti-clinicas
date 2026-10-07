import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../../core/utils/datas.dart';
import '../../../domain/models/evolution_model.dart';
import 'evolution_status_tag.dart';

/// Abre o modal com a [evolution] (padrão de [showAppModalSheet]).
Future<void> showEvolutionDetailsModal(
  BuildContext context,
  EvolutionModel evolution,
) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => EvolutionDetailsModal(evolution: evolution),
  );
}

/// Visualização da evolução (só leitura): sessão, profissional, status
/// do paciente, quem registrou e os textos. Campos vazios não aparecem.
class EvolutionDetailsModal extends StatelessWidget {
  final EvolutionModel evolution;

  const EvolutionDetailsModal({super.key, required this.evolution});

  @override
  Widget build(BuildContext context) {
    final escala = evolution.scale;

    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Área fixa (não rola): arrastar aqui fecha o modal.
          const AppSheetHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Cabecalho(evolution: evolution),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Symbols.schedule,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Registrado por ${evolution.registeredBy} - '
                          '${Datas.data(evolution.registeredAt)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Campo(
                    rotulo: 'DESCRIÇÃO DA SESSÃO',
                    texto: evolution.description,
                  ),
                  _Campo(
                    rotulo: 'OBSERVAÇÕES RELEVANTES',
                    texto: evolution.observations,
                  ),
                  _Campo(
                    rotulo: 'EVOLUÇÃO / PROGRESSO CLÍNICO',
                    texto: evolution.clinicalProgress,
                  ),
                  if (escala != null)
                    _Campo(
                      rotulo: 'ESCALA DE AVALIAÇÃO',
                      texto: '${escala.scale.label}: ${escala.result}',
                    ),
                ],
              ),
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

/// Card do topo: número e data da sessão, profissional e status.
class _Cabecalho extends StatelessWidget {
  final EvolutionModel evolution;

  const _Cabecalho({required this.evolution});

  @override
  Widget build(BuildContext context) {
    final status = evolution.patientStatus;

    return Container(
      decoration: AppDecorations.card.copyWith(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: const Border(),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sessão #${evolution.sessionNumber}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                Datas.data(evolution.sessionDate),
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: 32, color: Colors.grey[300]),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROFISSIONAL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evolution.professionalName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null) EvolutionStatusTag(status: status),
            ],
          ),
        ],
      ),
    );
  }
}

/// Um texto da evolução no seu card. Vazio, não aparece.
class _Campo extends StatelessWidget {
  final String rotulo;
  final String texto;

  const _Campo({required this.rotulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    if (texto.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card.copyWith(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.borderAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
