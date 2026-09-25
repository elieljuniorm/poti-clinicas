import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Botão de ação principal em formato de pílula.
///
/// Com [carregando] = `true`, mostra um indicador e ignora toques.
/// Com [contornado] = `true`, vira a variação secundária (fundo branco).
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool carregando;
  final bool contornado;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.carregando = false,
    this.contornado = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final corTexto = contornado ? AppColors.buttonPrimary : Colors.white;

    return SizedBox(
      height: 45,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: contornado
              ? AppColors.surface
              : AppColors.buttonPrimary,
          disabledBackgroundColor: contornado
              ? AppColors.surface
              : AppColors.buttonPrimary.withValues(alpha: 0.6),
          elevation: 0,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: contornado
                ? const BorderSide(color: AppColors.buttonPrimary, width: 2)
                : BorderSide.none,
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: corTexto, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.buttonLabel.copyWith(color: corTexto),
                  ),
                ],
              ),
      ),
    );
  }
}
