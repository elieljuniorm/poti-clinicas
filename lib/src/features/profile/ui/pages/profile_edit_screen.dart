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
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 50),
          child: ProfileEditForm(
            perfil: profileState.profile!,
            aoCancelar: () => context.goNamed('profile'),
          ),
        ),
      ),
    );
  }
}
