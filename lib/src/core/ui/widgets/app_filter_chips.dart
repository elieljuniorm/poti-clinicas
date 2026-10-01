import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Filtros em chips (ex.: Todos / Em Terapia / Novo / Pendente).
///
/// O chip escolhido fica escuro com texto branco; os outros, brancos.
/// Com muitos chips a linha rola na horizontal, sem quebrar.
class AppFilterChips<T> extends StatelessWidget {
  final List<T> opcoes;
  final T selecionado;
  final String Function(T opcao) rotulo;
  final ValueChanged<T> aoSelecionar;

  const AppFilterChips({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // A sombra/borda do chip não é cortada nas pontas.
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final opcao in opcoes) ...[
            _Chip(
              texto: rotulo(opcao),
              ativo: opcao == selecionado,
              onTap: () => aoSelecionar(opcao),
            ),
            if (opcao != opcoes.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Chip extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  const _Chip({required this.texto, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const raio = BorderRadius.all(Radius.circular(20));

    return Semantics(
      button: true,
      selected: ativo,
      child: Material(
        color: ativo ? AppColors.chipSelected : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: raio,
          side: BorderSide(
            color: ativo ? AppColors.chipSelected : AppColors.cardBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: raio,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ativo
                    ? AppColors.chipSelectedForeground
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
