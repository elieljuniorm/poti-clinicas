import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/utils/datas.dart';
import '../../../domain/models/evolution_model.dart';

/// Card da evolução mais recente: sessão, data, profissional e o texto.
/// Tocar abre a evolução completa ([aoAbrir]). Sem evolução, avisa que
/// nenhuma foi registrada.
class LatestEvolutionCard extends StatelessWidget {
  final EvolutionModel? evolution;
  final ValueChanged<EvolutionModel>? aoAbrir;

  const LatestEvolutionCard({super.key, required this.evolution, this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    final evolution = this.evolution;

    final aoAbrir = this.aoAbrir;

    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: evolution == null || aoAbrir == null
              ? null
              : () => aoAbrir(evolution),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _conteudo(evolution),
          ),
        ),
      ),
    );
  }

  Widget _conteudo(EvolutionModel? evolution) {
    return evolution == null
        ? const Text(
            'Nenhuma evolução registrada',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sessão #${evolution.sessionNumber} - '
                      '${Datas.data(evolution.sessionDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.borderAccent,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: 'Profissional: ',
                        style: const TextStyle(color: AppColors.textHint),
                        children: [TextSpan(text: evolution.professionalName)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                evolution.description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
  }
}
