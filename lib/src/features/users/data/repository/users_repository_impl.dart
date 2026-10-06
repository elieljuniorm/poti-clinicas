import '../../domain/models/user_details_model.dart';
import '../../domain/models/user_edit_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_registration_model.dart';
import '../../domain/repositories/users_repository.dart';
import '../data_sources/users_remote_data_source.dart';
import '../dtos/user_registration_dto.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Converte DTO → model. O domínio não conhece DTO.
class UsersRepositoryImpl implements UsersRepository {
  final UsersDataSource _dataSource;

  UsersRepositoryImpl(this._dataSource);

  @override
  Future<List<UserModel>> buscarUsuarios() async {
    final dtos = await _dataSource.buscarUsuarios();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<UserDetailsModel> buscarDetalhes(String userId) async {
    final dto = await _dataSource.buscarDetalhes(userId);
    return dto.toDomain();
  }

  @override
  Future<UserModel> cadastrarUsuario(UserRegistrationModel cadastro) async {
    final dto = await _dataSource.cadastrarUsuario(
      UserRegistrationDto.fromDomain(cadastro),
    );
    return dto.toDomain();
  }

  @override
  Future<UserEditModel> buscarCadastro(String userId) async {
    final resposta = await _dataSource.buscarCadastro(userId);
    return UserEditModel(
      user: resposta.usuario.toDomain(),
      cadastro: resposta.cadastro.toDomain(),
    );
  }

  @override
  Future<UserModel> atualizarUsuario(
    String userId,
    UserRegistrationModel cadastro,
  ) async {
    final dto = await _dataSource.atualizarUsuario(
      userId,
      UserRegistrationDto.fromDomain(cadastro),
    );
    return dto.toDomain();
  }

  @override
  Future<UserModel> alterarStatus(String userId, {required bool ativo}) async {
    final dto = await _dataSource.alterarStatus(userId, ativo: ativo);
    return dto.toDomain();
  }

  @override
  Future<void> resetarSenha(String userId) => _dataSource.resetarSenha(userId);
}
