import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Medidas padrão dos botões salvar/cancelar.
class AppActionButtonStyle {
  AppActionButtonStyle._(); // impede instanciação

  static const double largura = 185;
  static const double altura = 45;
  static const double raio = 25;

  /// Espaço entre os botões no [AppSaveCancelButtons].
  static const double espacamento = 30;
}

/// Botão "SALVAR" padrão: fundo #007952, texto branco em maiúsculas.
///
/// Com [carregando] = `true`, mostra um indicador e ignora toques.
class AppSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool carregando;

  /// Largura do botão. Padrão: [AppActionButtonStyle.largura]; maior para
  /// textos longos (ex.: "SALVAR ALTERAÇÕES").
  final double largura;

  const AppSaveButton({
    super.key,
    required this.onPressed,
    this.label = 'Salvar',
    this.carregando = false,
    this.largura = AppActionButtonStyle.largura,
  });

  @override
  Widget build(BuildContext context) {
    return _AppActionButton(
      label: label,
      corFundo: AppColors.buttonSave,
      onPressed: onPressed,
      carregando: carregando,
      largura: largura,
    );
  }
}

/// Botão "CANCELAR" padrão: fundo #E65100, texto branco em maiúsculas.
class AppCancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const AppCancelButton({
    super.key,
    required this.onPressed,
    this.label = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return _AppActionButton(
      label: label,
      corFundo: AppColors.buttonCancel,
      onPressed: onPressed,
    );
  }
}

/// Par salvar + cancelar na mesma linha, centralizado, com 30px entre eles.
///
/// Ocupa toda a largura disponível. Em telas estreitas os botões
/// encolhem igualmente para caber, sem estourar a linha.
/// Com [salvando] = `true`, o salvar mostra o indicador e o cancelar é desativado.
class AppSaveCancelButtons extends StatelessWidget {
  final VoidCallback? aoSalvar;
  final VoidCallback? aoCancelar;
  final bool salvando;
  final String labelSalvar;
  final String labelCancelar;

  const AppSaveCancelButtons({
    super.key,
    required this.aoSalvar,
    required this.aoCancelar,
    this.salvando = false,
    this.labelSalvar = 'Salvar',
    this.labelCancelar = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AppSaveButton(
              label: labelSalvar,
              carregando: salvando,
              onPressed: aoSalvar,
            ),
          ),
          const SizedBox(width: AppActionButtonStyle.espacamento),
          Flexible(
            child: AppCancelButton(
              label: labelCancelar,
              onPressed: salvando ? null : aoCancelar,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _AppActionButton extends StatelessWidget {
  final String label;
  final Color corFundo;
  final VoidCallback? onPressed;
  final bool carregando;
  final double largura;

  const _AppActionButton({
    required this.label,
    required this.corFundo,
    required this.onPressed,
    this.carregando = false,
    this.largura = AppActionButtonStyle.largura,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: AppActionButtonStyle.altura,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: corFundo,
          foregroundColor: AppColors.buttonActionForeground,
          disabledBackgroundColor: corFundo.withValues(alpha: 0.6),
          disabledForegroundColor: AppColors.buttonActionForeground,
          elevation: 0,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, AppActionButtonStyle.altura),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppActionButtonStyle.raio),
            ),
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.buttonActionForeground,
                ),
              )
            : Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: AppColors.buttonActionForeground,
                ),
              ),
      ),
    );
  }
}
