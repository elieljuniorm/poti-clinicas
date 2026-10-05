import '../../domain/models/patient_category.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class UserDto {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? description;
  final String? patientCategory;
  final String status;
  final String? photoUrl;
  final String? document;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.description,
    this.patientCategory,
    required this.status,
    this.photoUrl,
    this.document,
  });

  // JSON → DTO
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      description: json['description'],
      patientCategory: json['patient_category'],
      status: json['status'],
      photoUrl: json['photo_url'],
      document: json['document'],
    );
  }

  // DTO → Model de domínio
  UserModel toDomain() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: switch (role) {
        'professional' => UserRole.professional,
        'admin' => UserRole.admin,
        'reception' => UserRole.reception,
        'collaborator' => UserRole.collaborator,
        _ => UserRole.patient,
      },
      description: description,
      patientCategory: switch (patientCategory) {
        'pediatric' => PatientCategory.pediatric,
        'adult' => PatientCategory.adult,
        'elderly' => PatientCategory.elderly,
        _ => null,
      },
      active: status == 'active',
      photoUrl: photoUrl,
      document: document,
    );
  }
}
