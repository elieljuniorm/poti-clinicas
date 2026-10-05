import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Contador em pílula: [−] valor [+] (ex.: quantidade de sessões).
///
/// Os botões ficam desativados nos limites [minimo] e [maximo].
class AppQuantityStepper extends StatelessWidget {
  final int valor;
  final ValueChanged<int> aoMudar;
  final int minimo;
  final int maximo;
  final bool habilitado;

  /// Nome para leitores de tela (ex.: "Sessões").
  final String rotulo;

  const AppQuantityStepper({
    super.key,
    required this.valor,
    required this.aoMudar,
    required this.rotulo,
    this.minimo = 1,
    this.maximo = 99,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final podeDiminuir = habilitado && valor > minimo;
    final podeAumentar = habilitado && valor < maximo;

    return Semantics(
      label: rotulo,
      value: '$valor',
      increasedValue: podeAumentar ? '${valor + 1}' : null,
      decreasedValue: podeDiminuir ? '${valor - 1}' : null,
      onIncrease: podeAumentar ? () => aoMudar(valor + 1) : null,
      onDecrease: podeDiminuir ? () => aoMudar(valor - 1) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: habilitado ? AppColors.borderAccent : AppColors.textHint,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _Botao(
              icon: Symbols.remove,
              dica: 'Diminuir',
              onTap: podeDiminuir ? () => aoMudar(valor - 1) : null,
            ),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  '$valor',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fieldValue.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _Botao(
              icon: Symbols.add,
              dica: 'Aumentar',
              onTap: podeAumentar ? () => aoMudar(valor + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Botao extends StatelessWidget {
  final IconData icon;
  final String dica;
  final VoidCallback? onTap;

  const _Botao({required this.icon, required this.dica, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ativo = onTap != null;

    return Tooltip(
      message: dica,
      child: Material(
        color: AppColors.actionCardBackground.withValues(
          alpha: ativo ? 1 : 0.5,
        ),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 22,
              color: ativo ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}
