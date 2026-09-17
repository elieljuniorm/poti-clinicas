import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto reutilizáveis.
class AppTextStyles {
  AppTextStyles._();

  /// Saudação no topo do Drawer ("Olá, {{user}}").
  static const TextStyle drawerGreeting = TextStyle(
    color: AppColors.drawerForeground,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  /// Texto dos itens do menu do Drawer.
  static const TextStyle drawerItem = TextStyle(
    color: AppColors.drawerForeground,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// Texto abaixo do botão "Sair".
  static const TextStyle drawerLogoutLabel = TextStyle(
    color: AppColors.drawerForeground,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}