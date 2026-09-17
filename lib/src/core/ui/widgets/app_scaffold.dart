import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String titulo;
  final Widget body;
  final bool mostrarMenu;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final String? rotaAtual;

  const AppScaffold({
    super.key,
    required this.titulo,
    required this.body,
    this.mostrarMenu = true,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.rotaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: mostrarMenu ? AppDrawer(rotaAtual: rotaAtual) : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cabecalho(
              titulo: titulo,
              mostrarMenu: mostrarMenu,
              actions: actions,
            ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final String titulo;
  final bool mostrarMenu;
  final List<Widget>? actions;

  const _Cabecalho({
    required this.titulo,
    required this.mostrarMenu,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (mostrarMenu)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              const Spacer(),
              ...?actions,
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
