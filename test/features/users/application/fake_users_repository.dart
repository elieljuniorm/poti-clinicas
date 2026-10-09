import 'package:multiclinica_app/src/features/users/domain/models/consumption_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_details_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_edit_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_registration_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_role.dart';
import 'package:multiclinica_app/src/features/users/domain/repositories/users_repository.dart';

class FakeUsersRepository implements UsersRepository {
  bool deveFalhar;
  bool falharDetalhes;
  String? erroCadastro;
  String? erroEdicao;
  final List<String> detalhesBuscados = [];
  final List<UserRegistrationModel> cadastros = [];
  final List<UserRegistrationModel> edicoes = [];
  final List<bool> statusAlterados = [];
  final List<String> senhasResetadas = [];
  int buscasUsuarios = 0;

  /// Cadastro devolvido por [buscarCadastro], por id. Sem cadastro aqui,
  /// devolve só os dados da lista.
  final Map<String, UserRegistrationModel> cadastrosCompletos;

  FakeUsersRepository({
    this.deveFalhar = false,
    this.falharDetalhes = false,
    this.erroCadastro,
    this.erroEdicao,
    this.cadastrosCompletos = const {},
  });

  static const usuarios = [
    UserModel(
      id: '1',
      name: 'Arnaldo Ribeiro',
      email: 'arnaldo@5f.com',
      phone: '(91) 9 8455-1212',
      role: UserRole.professional,
    ),
    UserModel(
      id: '2',
      name: 'Antônio Araújo',
      email: 'antonio@gmail.com',
      phone: '(91) 9 9100-2020',
      role: UserRole.patient,
    ),
    UserModel(
      id: '3',
      name: 'Fernanda Lima',
      email: 'fernanda@5f.com',
      phone: '(91) 9 8765-4321',
      role: UserRole.reception,
    ),
  ];

  @override
  Future<List<UserModel>> buscarUsuarios() async {
    buscasUsuarios++;
    if (deveFalhar) throw Exception('sem conexão');
    return usuarios;
  }

  @override
  Future<UserDetailsModel> buscarDetalhes(String userId) async {
    detalhesBuscados.add(userId);
    if (falharDetalhes) throw Exception('sem conexão');
    return const UserDetailsModel(
      consumption: ConsumptionModel(
        contracted: 20,
        performed: 12,
        sessionValue: 180,
      ),
    );
  }

  @override
  Future<UserModel> cadastrarUsuario(UserRegistrationModel cadastro) async {
    final erro = erroCadastro;
    if (erro != null) throw Exception(erro);
    cadastros.add(cadastro);
    return UserModel(
      id: 'novo',
      name: cadastro.name,
      email: cadastro.email,
      phone: cadastro.phone,
      role: cadastro.role,
    );
  }

  final Map<String, bool> _ativos = {};

  UserModel _usuario(String userId) {
    final user = usuarios.firstWhere((u) => u.id == userId);
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      active: _ativos[userId] ?? user.active,
    );
  }

  @override
  Future<UserEditModel> buscarCadastro(String userId) async {
    if (falharDetalhes) throw Exception('sem conexão');
    final user = _usuario(userId);
    return UserEditModel(
      user: user,
      cadastro:
          cadastrosCompletos[userId] ??
          UserRegistrationModel(
            name: user.name,
            email: user.email,
            phone: user.phone,
            role: user.role,
            document: '',
          ),
    );
  }

  @override
  Future<UserModel> atualizarUsuario(
    String userId,
    UserRegistrationModel cadastro,
  ) async {
    final erro = erroEdicao;
    if (erro != null) throw Exception(erro);
    edicoes.add(cadastro);
    return UserModel(
      id: userId,
      name: cadastro.name,
      email: cadastro.email,
      phone: cadastro.phone,
      role: cadastro.role,
    );
  }

  @override
  Future<UserModel> alterarStatus(String userId, {required bool ativo}) async {
    final erro = erroEdicao;
    if (erro != null) throw Exception(erro);
    statusAlterados.add(ativo);
    _ativos[userId] = ativo;
    return _usuario(userId);
  }

  @override
  Future<void> resetarSenha(String userId) async {
    final erro = erroEdicao;
    if (erro != null) throw Exception(erro);
    senhasResetadas.add(userId);
  }
}
