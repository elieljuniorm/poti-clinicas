import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Item de menu em formato de pílula, usado dentro do [AppDrawer].
class DrawerMenuItem extends StatelessWidget {
  /// Ícone exibido à esquerda.
  final IconData icon;

  /// Texto do item.
  final String label;

  /// Se `true`, pinta com a cor de destaque (item selecionado).
  final bool isActive;

  /// Ação executada ao tocar.
  final VoidCallback onTap;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isActive ? AppColors.menuItemActive : AppColors.menuItem;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.drawerForeground, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.drawerItem,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}