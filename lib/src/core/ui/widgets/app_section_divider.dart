import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Divisor de áreas do formulário: linha nas pontas e título no centro
/// (ex.: "——— ENDEREÇO ———").
class AppSectionDivider extends StatelessWidget {
  final String titulo;

  const AppSectionDivider({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.dividerTextLine)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionDivider,
            ),
          ),
          const Expanded(child: Divider(color: AppColors.dividerTextLine)),
        ],
      ),
    );
  }
}
