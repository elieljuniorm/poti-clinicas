import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bottom_spacer.dart';
import '../widgets/app_scaffold.dart';

/// Tela provisória para rotas do menu que ainda não têm feature própria.
///
/// Mantém o [AppScaffold] (e portanto o menu lateral) funcionando.
/// Substitua pela tela real no `app_router.dart` quando a feature existir.
class EmConstrucaoScreen extends StatelessWidget {
  final String titulo;
  final String rotaAtual;

  const EmConstrucaoScreen({
    super.key,
    required this.titulo,
    required this.rotaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      titulo: titulo,
      rotaAtual: rotaAtual,
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: const Column(
            children: [
              // Centraliza na área visível, acima do menu inferior flutuante.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.construction,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    Text('EM CONSTRUÇÃO', style: AppTextStyles.sectionTitle),
                    SizedBox(height: 4),
                    Text(
                      'ESTA TELA ESTARÁ DISPONÍVEL EM BREVE',
                      style: AppTextStyles.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              AppBottomSpacer(folga: 0),
            ],
          ),
        ),
      ),
    );
  }
}
