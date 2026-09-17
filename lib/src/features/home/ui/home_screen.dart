import 'package:flutter/material.dart';
import '../../../core/ui/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      titulo: 'Bem-vindo(a)',
      rotaAtual: '/home',
      body: Center(child: Text('Hello world!')),
    );
  }
}