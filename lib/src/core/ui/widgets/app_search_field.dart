import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Campo de busca padrão: pílula branca com lupa à esquerda.
///
/// [destaque] = `true` usa a borda verde-azulada (ex.: Usuários);
/// `false`, a borda cinza suave (ex.: Prontuário).
class AppSearchField extends StatelessWidget {
  final String dica;
  final ValueChanged<String> aoBuscar;
  final bool destaque;

  const AppSearchField({
    super.key,
    required this.dica,
    required this.aoBuscar,
    this.destaque = false,
  });

  OutlineInputBorder _borda(Color cor, double largura) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corBorda = destaque ? AppColors.borderAccent : AppColors.cardBorder;
    final corIcone = destaque ? AppColors.borderAccent : AppColors.textHint;

    return TextField(
      onChanged: aoBuscar,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.fieldValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText: dica,
        hintStyle: AppTextStyles.formHint,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Icon(Symbols.search, color: corIcone),
        ),
        enabledBorder: _borda(corBorda, destaque ? 1.5 : 1),
        focusedBorder: _borda(AppColors.borderAccent, 2),
      ),
    );
  }
}
