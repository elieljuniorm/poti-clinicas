import 'package:flutter/material.dart';

/// Paleta central de cores da aplicação.
/// Ajuste os valores conforme o design final.
class AppColors {
  AppColors._(); // impede instanciação

  // ---------- Drawer / menu lateral ----------
  /// Fundo escuro do Drawer (verde-azulado escuro).
  static const Color drawerBackground = Color.fromRGBO(14, 90, 104, 1);

  /// Cor padrão dos itens do menu (turquesa).
  static const Color menuItem = Color(0xFF4BA3B8);

  /// Cor do item do menu quando está ativo/selecionado.
  static const Color menuItemActive = Color(0xFF7FCFDE);

  /// Texto e ícones sobre o Drawer.
  static const Color drawerForeground = Colors.white;

  // ---------- Menu inferior flutuante ----------
  /// Fundo do [AppBottomNav] (#197E90).
  static const Color bottomNavBackground = Color(0xFF197E90);

  /// Ícones do [AppBottomNav] (#FFFFFF). No item ativo, usado com 50% de opacidade.
  static const Color bottomNavForeground = Color(0xFFFFFFFF);

  /// Sombra de elementos flutuantes, como o [AppBottomNav] (preto 20%).
  static const Color floatingShadow = Color(0x33000000);

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

  /// Fundo do botão "SALVAR" ([AppSaveButton]) (#007952).
  static const Color buttonSave = Color(0xFF007952);

  /// Fundo do botão "CANCELAR" ([AppCancelButton]) (#E65100).
  static const Color buttonCancel = Color(0xFFE65100);

  /// Texto dos botões salvar/cancelar (#FFFFFF).
  static const Color buttonActionForeground = Color(0xFFFFFFFF);

  // ---------- Cards / tabelas ----------
  /// Borda dos cards (preto 20%).
  static const Color cardBorder = Color(0x33000000);

  /// Borda dos divisores de texto.
  static const Color dividerTextLine = Color.fromRGBO(2, 34, 43, 1);

  /// Sombra dos cards (preto 4%).
  static const Color cardShadow = Color(0x0A000000);

  static const Color tableRowEven = Color.fromRGBO(247, 246, 254, 1);
  static const Color tableRowOdd = Color.fromRGBO(238, 238, 238, 1);

  // ---------- Card de ação / seletor em segmentos ----------
  /// Fundo do [AppActionCard] (verde-azulado bem claro).
  static const Color actionCardBackground = Color.fromRGBO(233, 242, 245, 1);

  /// Fundo do [AppSegmentedControl].
  static const Color segmentedBackground = Color(0xFFE3E3E8);

  /// Fundo do [AppActionCard]
  static const Color textActionButton = Color.fromRGBO(25, 126, 144, 1);

  // ---------- Usuários (etiquetas de perfil) ----------
  static const Color roleProfessional = Color(0xFF1565C0);
  static const Color roleProfessionalBackground = Color(0xFFE3F0FD);
  static const Color rolePatient = Color(0xFFE65100);
  static const Color rolePatientBackground = Color(0xFFFFF1E0);
  static const Color roleAdmin = Color(0xFF6A1B9A);
  static const Color roleAdminBackground = Color(0xFFF3E5F5);
  static const Color roleReception = Color(0xFF00796B);
  static const Color roleReceptionBackground = Color(0xFFE0F2F1);
  static const Color roleCollaborator = Color(0xFF546E7A);
  static const Color roleCollaboratorBackground = Color(0xFFECEFF1);

  /// Etiqueta "Ativo" / "Inativo" do usuário.
  static const Color userActive = Color(0xFF2E7D32);
  static const Color userActiveBackground = Color(0xFFE8F5E9);
  static const Color userInactive = Color(0xFF757575);
  static const Color userInactiveBackground = Color(0xFFEEEEEE);

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
