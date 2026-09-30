import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';

/// Foto redonda do usuário, com ícone padrão quando não há foto.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double raio;

  const UserAvatar({super.key, this.photoUrl, this.raio = 26});

  @override
  Widget build(BuildContext context) {
    final temFoto = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: raio,
      backgroundColor: AppColors.menuItem,
      backgroundImage: temFoto ? NetworkImage(photoUrl!) : null,
      child: temFoto
          ? null
          : Icon(
              Symbols.person,
              size: raio * 1.1,
              fill: 1,
              color: Colors.white,
            ),
    );
  }
}
