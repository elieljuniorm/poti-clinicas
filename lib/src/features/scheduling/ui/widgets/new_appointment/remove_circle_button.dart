import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';

/// "x" em círculo vermelho claro (remover paciente, remover data).
class RemoveCircleButton extends StatelessWidget {
  final String dica;
  final VoidCallback? onTap;

  const RemoveCircleButton({super.key, required this.dica, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dica,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        // Área de toque maior que o círculo desenhado.
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.statusCanceled.withValues(alpha: 0.6),
                ),
              ),
              child: const Icon(
                Symbols.close,
                size: 16,
                color: AppColors.statusCanceled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
