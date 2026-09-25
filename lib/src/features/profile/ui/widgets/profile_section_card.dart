import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_text_styles.dart';

/// Card com título de seção e uma lista de campos.
class ProfileSectionCard extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.titulo,
    required this.children,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(titulo, style: AppTextStyles.sectionTitle),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(subtitulo!, style: AppTextStyles.sectionSubtitle),
        ],
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
