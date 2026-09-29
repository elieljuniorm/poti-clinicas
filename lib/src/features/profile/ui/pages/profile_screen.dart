import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/profile_controller.dart';
import '../states/profile_state.dart';
import '../widgets/profile_details.dart';

/// Tela "Meus dados" (visualização). Aberta pelo cabeçalho do Drawer.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return AppScaffold(
      titulo: 'Perfil',
      rotaAtual: '/profile',
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            children: [
              ProfileDetails(
                perfil: profileState.profile!,
                aoEditar: () => context.goNamed('profile-edit'),
              ),
              // Espaço para o menu inferior flutuante
              const AppBottomSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
