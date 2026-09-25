import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';

/// Foto + nome no topo das telas de perfil.
class ProfileHeader extends StatelessWidget {
  final String nome;
  final String? fotoUrl;

  const ProfileHeader({super.key, required this.nome, this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final temFoto = fotoUrl != null && fotoUrl!.isNotEmpty;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary, // cor da borda
              width: 2, // espessura da borda
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.menuItem,
            backgroundImage: temFoto ? NetworkImage(fotoUrl!) : null,
            child: temFoto
                ? null
                : const Icon(
                    Symbols.person,
                    size: 40,
                    fill: 1,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(nome, textAlign: TextAlign.center, style: AppTextStyles.pageTitle),
      ],
    );
  }
}
