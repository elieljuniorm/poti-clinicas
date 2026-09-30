import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Seletor em segmentos (ex.: Dia / Semana / Mês, Todos / Profissionais /
/// Pacientes). Cada valor de [opcoes] vira um segmento com o texto de [rotulo].
class AppSegmentedControl<T> extends StatelessWidget {
  final List<T> opcoes;
  final T selecionado;
  final String Function(T opcao) rotulo;
  final ValueChanged<T> aoSelecionar;

  const AppSegmentedControl({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.segmentedBackground,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          for (final opcao in opcoes)
            Expanded(
              child: _Segmento(
                texto: rotulo(opcao),
                ativo: opcao == selecionado,
                onTap: () => aoSelecionar(opcao),
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

class _Segmento extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  const _Segmento({
    required this.texto,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: ativo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ativo ? AppColors.surface : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            boxShadow: ativo
                ? const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: ativo ? FontWeight.bold : FontWeight.w400,
              color: ativo ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}
