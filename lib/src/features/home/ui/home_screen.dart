import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/widgets/app_scaffold.dart';
import '../../auth/application/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider);

    return AppScaffold(
      titulo: 'Bem-vindo(a)',
      rotaAtual: '/home',
      body: Center(child: Text('Hello world! ${usuario?.name ?? 'Usuário'}')),
    );
  }
}
