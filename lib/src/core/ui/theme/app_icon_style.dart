import 'package:flutter/material.dart';

/// Estilo central dos ícones Material Symbols (Google Fonts Icons).
/// Aplicado no tema do app (`main.dart`), vale para todo [Icon] do sistema.
///
/// Só os ícones `Symbols.*` respondem a estes ajustes (fonte variável).
/// Os `Icons.*` do Flutter usam fonte fixa e não mudam.
class AppIconStyle {
  AppIconStyle._(); // impede instanciação

  /// Espessura do traço: 100 (fino) a 700 (grosso). Padrão do Google: 400.
  static const double weight = 400;

  /// Ajuste fino da espessura: -25 (mais leve) a 200 (mais pesado). Padrão: 0.
  static const double grade = 10;

  /// Tamanho óptico: 20 a 48. Deixe próximo do tamanho em que o ícone aparece.
  static const double opticalSize = 30;

  /// Preenchimento: 0 (contornado) ou 1 (preenchido).
  static const double fill = 0;

  /// Tema de ícones usado no [ThemeData] do app.
  static const IconThemeData theme = IconThemeData(
    weight: weight,
    grade: grade,
    opticalSize: opticalSize,
    fill: fill,
  );
}
