import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';

/// Card-botão de ação principal da tela (ex.: "Novo Atendimento",
/// "Cadastrar Usuário"): ícone redondo, título, descrição e seta.
class AppActionCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final VoidCallback onTap;
  final IconData icon;

  const AppActionCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.onTap,
    this.icon = Symbols.add,
  });

  static const _raio = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.actionCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: _raio,
        side: BorderSide(color: AppColors.borderAccent),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: _raio,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.borderAccent,
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.borderAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.chevron_right,
                color: AppColors.borderAccent,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
