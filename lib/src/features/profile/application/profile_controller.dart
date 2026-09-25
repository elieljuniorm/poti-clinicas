import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/data_sources/profile_remote_data_source.dart';
import '../data/repository/profile_repository_impl.dart';
import '../domain/models/profile_model.dart';
import '../domain/repositories/profile_repository.dart';
import '../ui/states/profile_state.dart';

/// Carrega e guarda o perfil do usuário logado.
/// Compartilhado pelas telas de visualização e de edição.
class ProfileController extends Notifier<ProfileState> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  // Reconstrói só quando o usuário logado muda (login/logout),
  // e não a cada alteração de nome/e-mail na sessão.
  @override
  ProfileState build() {
    final userId = ref.watch(authControllerProvider.select((u) => u?.id));

    if (userId == null) {
      return const ProfileState(errorMessage: 'Nenhum usuário logado');
    }

    Future.microtask(carregar);
    return const ProfileState(isLoading: true);
  }

  Future<void> carregar() async {
    final userId = ref.read(authControllerProvider)?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final perfil = await _repository.buscarPerfil(userId);
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = ProfileState(profile: perfil);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Substitui o perfil em memória (chamado após salvar a edição).
  void definirPerfil(ProfileModel perfil) {
    state = ProfileState(profile: perfil);
  }
}

// ============================================================
// Providers
// ============================================================

final profileDataSourceProvider = Provider<ProfileDataSource>(
  (ref) => ProfileDataSource(),
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileDataSourceProvider));
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
