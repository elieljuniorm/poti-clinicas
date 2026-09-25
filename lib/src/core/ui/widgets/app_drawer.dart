import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/application/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'drawer_menu_item.dart';

class AppDrawer extends ConsumerWidget {
  /// Rota atual — usada para marcar o item ativo.
  final String? rotaAtual;

  const AppDrawer({super.key, this.rotaAtual});

  static const List<_DrawerEntry> _entradas = [
    _DrawerEntry(label: 'Início', icon: Icons.home_outlined, rota: '/home'),
    _DrawerEntry(
      label: 'Usuário',
      icon: Icons.person_outline,
      rota: '/usuario',
    ),
    _DrawerEntry(
      label: 'Agenda',
      icon: Icons.calendar_today_outlined,
      rota: '/agenda',
    ),
    _DrawerEntry(
      label: 'Prontuário',
      icon: Icons.assignment_ind_outlined,
      rota: '/prontuario',
    ),
    _DrawerEntry(label: 'Histórico', icon: Icons.history, rota: '/historico'),
    _DrawerEntry(
      label: 'Financeiro',
      icon: Icons.bar_chart,
      rota: '/financeiro',
    ),
  ];

  void _aoTocarItem(BuildContext context, _DrawerEntry entrada) {
    Navigator.pop(context);

    if (rotaAtual == entrada.rota) return;

    context.go(entrada.rota);
  }

  void _aoTocarCabecalho(BuildContext context) {
    Navigator.pop(context);

    if (rotaAtual == '/profile') return;

    context.goNamed('profile');
  }

  Future<void> _aoSair(BuildContext context, WidgetRef ref) async {
    // 1. Fecha o Drawer
    Navigator.pop(context);

    // 2. Limpa a sessão
    await ref.read(authControllerProvider.notifier).logout();

    // 3. Volta para o login (substitui a pilha)
    if (context.mounted) {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider);

    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      width: MediaQuery.of(context).size.width * 0.78,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ---------- Foto + saudação (clicável → Meus dados) ----------
            _CabecalhoUsuario(
              nome: usuario?.name ?? 'Visitante',
              fotoUrl: usuario?.photoUrl,
              onTap: usuario == null ? null : () => _aoTocarCabecalho(context),
            ),

            const SizedBox(height: 32),

            // ---------- Itens do menu ----------
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _entradas.length,
                itemBuilder: (context, index) {
                  final entrada = _entradas[index];
                  return DrawerMenuItem(
                    icon: entrada.icon,
                    label: entrada.label,
                    isActive: rotaAtual == entrada.rota,
                    onTap: () => _aoTocarItem(context, entrada),
                  );
                },
              ),
            ),

            // ---------- Botão Sair ----------
            _BotaoSair(onTap: () => _aoSair(context, ref)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _DrawerEntry {
  final String label;
  final IconData icon;
  final String rota;

  const _DrawerEntry({
    required this.label,
    required this.icon,
    required this.rota,
  });
}

class _CabecalhoUsuario extends StatelessWidget {
  final String nome;
  final String? fotoUrl;
  final VoidCallback? onTap;

  const _CabecalhoUsuario({required this.nome, this.fotoUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    final temFoto = fotoUrl != null && fotoUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.menuItem, width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.menuItem,
                  backgroundImage: temFoto ? NetworkImage(fotoUrl!) : null,
                  child: temFoto
                      ? null
                      : const Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text('Olá, $nome', style: AppTextStyles.drawerGreeting),
              if (onTap != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver meus dados',
                      style: AppTextStyles.drawerProfileLink,
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.menuItemActive,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoSair extends StatelessWidget {
  final VoidCallback onTap;

  const _BotaoSair({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Column(
        children: [
          Material(
            color: AppColors.menuItem,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.logout,
                  color: AppColors.drawerForeground,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Sair', style: AppTextStyles.drawerLogoutLabel),
        ],
      ),
    );
  }
}
