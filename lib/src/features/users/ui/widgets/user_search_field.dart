import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';

/// Campo "Buscar usuário" (por nome ou e-mail).
class UserSearchField extends StatelessWidget {
  final ValueChanged<String> aoBuscar;

  const UserSearchField({super.key, required this.aoBuscar});

  OutlineInputBorder _borda(double largura) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppColors.borderAccent, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: aoBuscar,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.fieldValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText: 'Buscar usuário',
        hintStyle: AppTextStyles.formHint,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(Symbols.search, color: AppColors.borderAccent),
        ),
        enabledBorder: _borda(1.5),
        focusedBorder: _borda(2),
      ),
    );
  }
}
