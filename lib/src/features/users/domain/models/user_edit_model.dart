import 'user_model.dart';
import 'user_registration_model.dart';

/// Dados abertos na tela "Editar Usuário": o [user] (foto, perfil e
/// situação ativo/inativo) e o [cadastro] completo que preenche o
/// mesmo formulário do cadastro.
class UserEditModel {
  final UserModel user;
  final UserRegistrationModel cadastro;

  const UserEditModel({required this.user, required this.cadastro});
}
