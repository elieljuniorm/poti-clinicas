import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_action_card.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_segmented_control.dart';
import '../../application/users_controller.dart';
import '../../domain/models/user_filter.dart';
import '../states/users_state.dart';
import '../widgets/user_card.dart';
import '../widgets/user_details_modal.dart';
import '../widgets/user_search_field.dart';

/// Lista todos os usuários do sistema (profissionais, pacientes,
/// administradores, recepção e colaboradores).
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersControllerProvider);
    final controller = ref.read(usersControllerProvider.notifier);

    return AppScaffold(
      titulo: 'Usuários',
      rotaAtual: '/usuario',
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: SingleChildScrollView(
            // Arrastar a lista fecha o teclado da busca.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserSearchField(aoBuscar: controller.buscar),
                const SizedBox(height: 20),

                AppActionCard(
                  titulo: 'Cadastrar Usuário',
                  descricao: 'Cadastre pacientes e profissionais para vincular aos atendimentos',
                  onTap: () => context.goNamed('usuario-novo'),
                ),
                const SizedBox(height: 20),

                AppSegmentedControl<UserFilter>(
                  opcoes: UserFilter.values,
                  rotulo: (filtro) => filtro.label,
                  selecionado: usersState.filter,
                  aoSelecionar: controller.selecionarFiltro,
                ),
                const SizedBox(height: 20),

                // Só a lista mostra loading/erro: busca e filtro continuam visíveis.
                _buildLista(usersState),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLista(UsersState usersState) {
    if (usersState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (usersState.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(usersState.errorMessage!, textAlign: TextAlign.center),
      );
    }

    final usuarios = usersState.filteredUsers;
    if (usuarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'Nenhum usuário encontrado',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        return UserCard(
          user: usuario,
          onTap: () => showUserDetailsModal(context, usuario),
        );
      },
    );
  }
}
