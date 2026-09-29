import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';

/// Menu inferior flutuante (bottom app bar de navegação).
///
/// Fica afastado da base e das laterais, com cantos arredondados.
/// O item da rota atual aparece com 50% de opacidade e não navega.
///
/// Não use direto nas páginas: o [AppScaffold] já o exibe
/// (controlado por `mostrarMenuInferior` e `rotaAtual`).
class AppBottomNav extends StatelessWidget {
  /// Rota atual — usada para marcar o item ativo.
  final String? rotaAtual;

  const AppBottomNav({super.key, this.rotaAtual});

  /// Altura da barra (sem as margens).
  static const double altura = 55;

  static const List<_BottomNavEntry> _entradas = [
    _BottomNavEntry(label: 'Início', icon: Symbols.home, rota: '/home'),
    _BottomNavEntry(
      label: 'Agenda',
      icon: Symbols.calendar_clock,
      rota: '/agenda',
    ),
    _BottomNavEntry(
      label: 'Prontuário',
      icon: Symbols.conditions,
      rota: '/prontuario',
    ),
    _BottomNavEntry(
      label: 'Histórico',
      icon: Symbols.manage_history,
      rota: '/historico',
    ),
  ];

  /// Ativo na própria rota e nas sub-rotas (ex.: `/agenda/novo`).
  bool _estaAtivo(_BottomNavEntry entrada) {
    final rota = rotaAtual;
    if (rota == null) return false;
    return rota == entrada.rota || rota.startsWith('${entrada.rota}/');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // Afastamento da base e das laterais (efeito flutuante)
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: AppColors.floatingShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BottomAppBar(
              color: AppColors.bottomNavBackground,
              height: altura,
              padding: EdgeInsets.zero,
              elevation: 0,
              child: Row(
                children: [
                  for (final entrada in _entradas)
                    _BotaoNavegacao(
                      entrada: entrada,
                      ativo: _estaAtivo(entrada),
                      onTap: () => context.go(entrada.rota),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _BottomNavEntry {
  final String label;
  final IconData icon;
  final String rota;

  const _BottomNavEntry({
    required this.label,
    required this.icon,
    required this.rota,
  });
}

class _BotaoNavegacao extends StatelessWidget {
  final _BottomNavEntry entrada;
  final bool ativo;
  final VoidCallback onTap;

  const _BotaoNavegacao({
    required this.entrada,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: ativo,
        label: entrada.label,
        excludeSemantics: true,
        child: Tooltip(
          message: entrada.label,
          child: InkResponse(
            // Na página ativa o toque não faz nada (evita recarregar a tela).
            onTap: ativo ? null : onTap,
            radius: 28,
            child: SizedBox(
              height: AppBottomNav.altura,
              child: Center(
                child: Icon(
                  entrada.icon,
                  size: 35,
                  color: AppColors.bottomNavForeground.withValues(
                    alpha: ativo ? 0.5 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
