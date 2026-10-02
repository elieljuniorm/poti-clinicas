import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';

/// Foto redonda de uma pessoa (usuário, profissional, paciente).
///
/// Sem foto: mostra as iniciais de [nome] (ex.: "LM"), se informado,
/// ou o ícone padrão de pessoa.
class AppAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String? nome;
  final double raio;

  const AppAvatar({super.key, this.fotoUrl, this.nome, this.raio = 26});

  /// "Lucas Morais" → "LM"; "Dr. Arnaldo Ribeiro" → "AR"; "Ana" → "A".
  static String iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        // Títulos não entram nas iniciais.
        .where((p) => p.isNotEmpty && !RegExp(r'\.$').hasMatch(p))
        .toList();
    if (partes.isEmpty) return '';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = this.fotoUrl;
    final temFoto = fotoUrl != null && fotoUrl.isNotEmpty;
    final iniciais = nome == null ? '' : AppAvatar.iniciais(nome!);

    if (temFoto) {
      return CircleAvatar(
        radius: raio,
        backgroundColor: AppColors.menuItem,
        backgroundImage: NetworkImage(fotoUrl),
      );
    }

    if (iniciais.isNotEmpty) {
      return CircleAvatar(
        radius: raio,
        backgroundColor: AppColors.actionCardBackground,
        child: Text(
          iniciais,
          style: TextStyle(
            fontSize: raio * 0.62,
            fontWeight: FontWeight.w600,
            color: AppColors.borderAccent,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: raio,
      backgroundColor: AppColors.menuItem,
      child: Icon(
        Symbols.person,
        size: raio * 1.1,
        fill: 1,
        color: Colors.white,
      ),
    );
  }
}
