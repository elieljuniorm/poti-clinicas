import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto reutilizáveis.
class AppTextStyles {
  AppTextStyles._();

  // ---------- Telas ----------
  /// Título grande do topo das telas logadas ([AppScaffold]).
  static const TextStyle pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Título de seção (ex.: "ATENDIMENTOS DO DIA").
  static const TextStyle sectionTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: AppColors.primary,
  );

  /// Subtítulo cinza abaixo do título de seção.
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // ---------- Formulários ----------
  /// Rótulo acima dos campos (ex.: "EMAIL").
  static const TextStyle formLabel = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  /// Placeholder dos campos.
  static const TextStyle formHint = TextStyle(
    color: AppColors.textHint,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Texto dos botões principais.
  static const TextStyle buttonLabel = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ---------- Drawer ----------
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
