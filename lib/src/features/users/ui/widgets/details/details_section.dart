import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';

/// Seção do modal de detalhes: título em caixa alta + conteúdo.
class DetailsSection extends StatelessWidget {
  final String titulo;
  final Widget child;

  const DetailsSection({super.key, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: AppTextStyles.detailsSectionTitle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Bloco cinza arredondado usado dentro das seções.
class DetailsPanel extends StatelessWidget {
  final Widget child;

  const DetailsPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}

/// Rótulo cinza + valor em negrito, centralizados (ex.: "Início / 15/03/2025").
class DetailsInfo extends StatelessWidget {
  final String rotulo;
  final Widget valor;

  const DetailsInfo({super.key, required this.rotulo, required this.valor});

  DetailsInfo.texto({super.key, required this.rotulo, required String valor})
    : valor = Text(
        valor,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rotulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
        ),
        const SizedBox(height: 4),
        valor,
      ],
    );
  }
}

/// Linha "rótulo ........ valor" (ex.: "Valor por sessão   R$ 180,00").
class DetailsRow extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color corValor;

  const DetailsRow({
    super.key,
    required this.rotulo,
    required this.valor,
    this.corValor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: corValor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de lista com ícone em quadrado claro, título e linha de apoio
/// (ex.: sessões recentes, próximos atendimentos).
class DetailsListItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String data;
  final String destaque;

  const DetailsListItem({
    super.key,
    required this.icon,
    required this.titulo,
    required this.data,
    required this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          DetailsIconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: data,
                        style: const TextStyle(color: AppColors.textHint),
                      ),
                      const TextSpan(text: '   '),
                      TextSpan(
                        text: destaque,
                        style: const TextStyle(color: AppColors.borderAccent),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícone verde-azulado dentro de um quadrado claro arredondado.
class DetailsIconBox extends StatelessWidget {
  final IconData icon;

  const DetailsIconBox({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.actionCardBackground,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Icon(icon, size: 20, color: AppColors.borderAccent),
    );
  }
}

/// Etiqueta de status (ex.: "Ativo", "Vencido").
class DetailsStatusTag extends StatelessWidget {
  final String texto;
  final bool positivo;

  const DetailsStatusTag({
    super.key,
    required this.texto,
    required this.positivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: positivo
            ? AppColors.userActiveBackground
            : AppColors.userInactiveBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: positivo ? AppColors.userActive : AppColors.userInactive,
        ),
      ),
    );
  }
}

/// Formata valores em reais (ex.: 180.0 → "R$ 180,00").
String formatarReais(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
