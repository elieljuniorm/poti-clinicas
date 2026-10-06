import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Seta de voltar no cabeçalho do [AppScaffold], na ponta direita da
/// linha do menu (use em `actions`).
///
/// Volta para a tela anterior. Sem tela anterior (ex.: aberta direto pelo
/// endereço), vai para a rota [rotaAnterior].
class AppBackButton extends StatelessWidget {
  /// Nome da rota usada quando não há para onde voltar (ex.: 'agenda').
  final String rotaAnterior;

  /// Parâmetros da [rotaAnterior] (ex.: `{'patientId': '2'}`).
  final Map<String, String> parametros;

  const AppBackButton({
    super.key,
    required this.rotaAnterior,
    this.parametros = const {},
  });

  void _voltar(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(rotaAnterior, pathParameters: parametros);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mesmo tamanho e alinhamento do botão do menu, espelhado à direita.
    return IconButton(
      tooltip: 'Voltar',
      icon: const Icon(Symbols.arrow_back, size: 28),
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      onPressed: () => _voltar(context),
    );
  }
}
