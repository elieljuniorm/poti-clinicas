import 'package:flutter/material.dart';

/// Paleta central de cores da aplicação.
/// Ajuste os valores conforme o design final.
class AppColors {
  AppColors._(); // impede instanciação

  // ---------- Drawer / menu lateral ----------
  /// Fundo escuro do Drawer (verde-azulado escuro).
  static const Color drawerBackground = Color(0xFF0F4C5C);

  /// Cor padrão dos itens do menu (turquesa).
  static const Color menuItem = Color(0xFF4BA3B8);

  /// Cor do item do menu quando está ativo/selecionado.
  static const Color menuItemActive = Color(0xFF7FCFDE);

  /// Texto e ícones sobre o Drawer.
  static const Color drawerForeground = Colors.white;

  // ---------- App geral ----------
  static const Color primary = Color(0xFF0F4C5C);
  static const Color accent = Color(0xFF4BA3B8);
  static const Color background = Color.fromRGBO(210, 221, 225, 1);
  static const Color surface = Colors.white;

  /// Fundo cinza-claro do corpo das telas logadas.
  static const Color surfaceMuted = Color(0xFFF2F2F7);

  // ---------- Formulários / botões ----------
  /// Bordas e ícones em verde-azulado (inputs, ícones de card).
  static const Color borderAccent = Color.fromRGBO(25, 126, 144, 1);

  /// Botão de ação principal (ex.: "ENTRAR").
  static const Color buttonPrimary = Color.fromRGBO(0, 121, 107, 1);

  // ---------- Cards / tabelas ----------
  /// Borda dos cards (preto 20%).
  static const Color cardBorder = Color(0x33000000);

  /// Sombra dos cards (preto 4%).
  static const Color cardShadow = Color(0x0A000000);

  static const Color tableRowEven = Color.fromRGBO(247, 246, 254, 1);
  static const Color tableRowOdd = Color.fromRGBO(238, 238, 238, 1);

  // ---------- Status ----------
  static const Color statusConfirmed = Colors.green;
  static const Color statusPending = Colors.orange;
  static const Color statusCanceled = Colors.redAccent;
  static const Color error = Colors.red;

  // ---------- Texto ----------
  static const Color textPrimary = Color.fromRGBO(2, 34, 43, 1);
  static const Color textSecondary = Color.fromRGBO(2, 34, 43, 1);
  static const Color textHint = Color.fromRGBO(141, 141, 141, 1);
  static const Color textOnDark = Colors.white;
}
