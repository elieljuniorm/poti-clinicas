import '../../../auth/domain/models/user.dart';
import '../../domain/repositories/login_repository.dart';
import '../data_sources/login_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (User).
/// Combina fontes, converte DTO → User. O domínio não conhece DTO.
class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource _dataSource;

  LoginRepositoryImpl(this._dataSource);

  @override
  Future<User> login(String email, String password) async {
    final dto = await _dataSource.login(email, password);
    return dto.toDomain();
  }
}
