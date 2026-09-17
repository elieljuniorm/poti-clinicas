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
  static const Color background = Color.fromRGBO(210, 221, 225, 1,);
  static const Color surface = Colors.white;

  // ---------- Texto ----------
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnDark = Colors.white;
}