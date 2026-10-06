import '../../domain/models/user_edit_model.dart';
import '../../domain/models/user_model.dart';

/// Carregamento do cadastro aberto na tela "Editar Usuário".
class UserEditDataState {
  final bool isLoading;
  final String? errorMessage;
  final UserEditModel? dados;

  const UserEditDataState({
    this.isLoading = false,
    this.errorMessage,
    this.dados,
  });

  UserEditDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserEditModel? dados,
  }) {
    return UserEditDataState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      dados: dados ?? this.dados,
    );
  }
}

/// Ações da tela "Editar Usuário".
enum UserEditAction { salvar, alterarStatus, resetarSenha }

sealed class UserEditState {
  const UserEditState();
}

class UserEditInitial extends UserEditState {
  const UserEditInitial();
}

/// Uma ação em andamento: as outras ficam bloqueadas até ela terminar.
class UserEditInProgress extends UserEditState {
  final UserEditAction acao;
  const UserEditInProgress(this.acao);
}

class UserEditSuccess extends UserEditState {
  final UserEditAction acao;

  /// Usuário como ficou depois da ação.
  final UserModel user;
  const UserEditSuccess(this.acao, this.user);
}

class UserEditError extends UserEditState {
  final String message;
  const UserEditError(this.message);
}
