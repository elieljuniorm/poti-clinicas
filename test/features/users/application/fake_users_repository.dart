import 'package:poti_5f/src/features/users/domain/models/consumption_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_details_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';
import 'package:poti_5f/src/features/users/domain/repositories/users_repository.dart';

class FakeUsersRepository implements UsersRepository {
  bool deveFalhar;
  bool falharDetalhes;
  final List<String> detalhesBuscados = [];

  FakeUsersRepository({this.deveFalhar = false, this.falharDetalhes = false});

  static const usuarios = [
    UserModel(
      id: '1',
      name: 'Dr. Arnaldo Ribeiro',
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
}
