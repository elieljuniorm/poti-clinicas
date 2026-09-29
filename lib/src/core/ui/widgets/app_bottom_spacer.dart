import 'package:flutter/material.dart';

/// Espaço no fim do conteúdo das páginas para ele não ficar escondido
/// atrás do menu inferior flutuante ([AppBottomNav]).
///
/// Coloque como **último filho** do conteúdo rolável do `body` do [AppScaffold].
/// A altura vem do `MediaQuery` do próprio widget (que, dentro do
/// [AppScaffold], já inclui a altura do menu e a área segura do aparelho),
/// por isso ele se ajusta sozinho quando o menu some (teclado aberto,
/// `mostrarMenuInferior: false`).
class AppBottomSpacer extends StatelessWidget {
  /// Folga extra acima do menu.
  final double folga;

  const AppBottomSpacer({super.key, this.folga = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).bottom + folga);
  }
}
