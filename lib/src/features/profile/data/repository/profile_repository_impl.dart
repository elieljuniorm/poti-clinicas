import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';
import '../dtos/profile_dto.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (model).
/// Converte DTO ↔ model. O domínio não conhece DTO.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<ProfileModel> buscarPerfil(String userId) async {
    final dto = await _dataSource.buscarPerfil(userId);
    return dto.toDomain();
  }

  @override
  Future<ProfileModel> atualizarPerfil(ProfileModel perfil) async {
    final dto = await _dataSource.atualizarPerfil(
      ProfileDto.fromDomain(perfil),
    );
    return dto.toDomain();
  }

  @override
  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) {
    return _dataSource.alterarSenha(
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );
  }
}
