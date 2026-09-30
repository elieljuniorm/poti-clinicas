import 'patient_category.dart';
import 'user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  /// Especialidade do profissional ou setor da equipe interna
  /// (ex.: "Fisioterapeuta", "Financeiro"). Não é usada para pacientes.
  final String? description;

  /// Categoria do paciente (Pediatria, Adulto, Idoso).
  final PatientCategory? patientCategory;
  final bool active;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.description,
    this.patientCategory,
    this.active = true,
    this.photoUrl,
  });

  /// Texto exibido ao lado do perfil no card: a categoria para pacientes,
  /// a descrição para os demais perfis.
  String? get detail =>
      role == UserRole.patient ? patientCategory?.label : description;
}
