import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Espaço livre acima dos modais: altura do cabeçalho do [AppScaffold]
/// (botão do menu + título da página), que continua visível e escurecido.
const double _espacoTopo = 110;

/// Abre um modal de baixo para cima no padrão do app (ex.: dados do
/// usuário, editar agendamento):
///
/// - Abre pelo navigator raiz: fica por cima do menu inferior e do Drawer,
///   escurecendo a página por trás.
/// - A altura máxima deixa o título da página visível.
/// - Arrastar a parte fixa do topo ([AppSheetHandle]) para baixo fecha o
///   modal; o conteúdo rola por dentro, sem fechar.
/// - Com o teclado aberto, o conteúdo sobe junto.
Future<T?> showAppModalSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final tela = MediaQuery.of(context);
  final alturaMaxima = tela.size.height - tela.padding.top - _espacoTopo;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    constraints: BoxConstraints(maxHeight: alturaMaxima),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (contexto) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(contexto).bottom,
      ),
      child: builder(contexto),
    ),
  );
}

/// Barra cinza do topo dos modais (indicador de arrastar para fechar).
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Arraste para baixo para fechar',
      child: SizedBox(
        height: 32,
        child: Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
