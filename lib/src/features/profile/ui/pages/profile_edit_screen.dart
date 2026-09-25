import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/profile_controller.dart';
import '../../application/profile_edit_controller.dart';
import '../states/profile_edit_state.dart';
import '../states/profile_state.dart';
import '../widgets/profile_edit_form.dart';

/// Tela "Editar dados" (variação de edição da [ProfileScreen]).
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // Com o dedo no mapa, a página para de rolar e o arraste move o mapa.
  bool _usandoMapa = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileEditState>(profileEditControllerProvider, (
      previous,
      next,
    ) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior
      // em vez de esperar na fila (ex.: erro seguido de sucesso).
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (next is ProfileEditSuccess) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso')),
        );
        context.goNamed('profile');
      }
      if (next is ProfileEditError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final profileState = ref.watch(profileControllerProvider);

    return AppScaffold(
      titulo: 'Editar Perfil',
      rotaAtual: '/profile/edit',
      backgroundColor: AppColors.background,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.errorMessage != null
          ? Center(child: Text(profileState.errorMessage!))
          : _buildBody(context, profileState),
    );
  }

  void _aoUsarMapa(bool usando) {
    if (usando != _usandoMapa) setState(() => _usandoMapa = usando);
  }

  Widget _buildBody(BuildContext context, ProfileState profileState) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: AppColors.surfaceMuted,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: _usandoMapa ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 50),
          child: ProfileEditForm(
            perfil: profileState.profile!,
            aoCancelar: () => context.goNamed('profile'),
            aoUsarMapa: _aoUsarMapa,
          ),
        ),
      ),
    );
  }
}
