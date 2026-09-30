import 'user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  /// Especialidade do profissional ou tratamento do paciente
  /// (ex.: "Fisioterapeuta", "Tratamento da Dor").
  final String? description;
  final bool active;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.description,
    this.active = true,
    this.photoUrl,
  });
}
