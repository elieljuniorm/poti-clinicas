import '../../domain/models/user_details_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/users_repository.dart';
import '../data_sources/users_remote_data_source.dart';

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
}
