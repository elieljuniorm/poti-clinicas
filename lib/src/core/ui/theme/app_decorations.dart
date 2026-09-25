import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Decorações reutilizáveis (cards, containers).
class AppDecorations {
  AppDecorations._();

  /// Card branco padrão: raio 12, borda suave e sombra leve.
  static const BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}
