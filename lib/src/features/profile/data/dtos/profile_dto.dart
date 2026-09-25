import '../../domain/models/profile_model.dart';
import 'address_dto.dart';

/// Representa o perfil exatamente como a API envia
/// e sabe se converter para o model do domínio (e voltar).
class ProfileDto {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String cpf;
  final String birthDate;
  final String? photoUrl;
  final AddressDto address;

  ProfileDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.birthDate,
    required this.address,
    this.photoUrl,
  });

  // JSON → DTO
  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      cpf: json['cpf'] ?? '',
      birthDate: json['birth_date'] ?? '',
      photoUrl: json['photo_url'],
      address: AddressDto.fromJson(json['address'] ?? const {}),
    );
  }

  // Model de domínio → DTO (usado ao salvar)
  factory ProfileDto.fromDomain(ProfileModel model) {
    return ProfileDto(
      userId: model.id,
      fullName: model.name,
      email: model.email,
      phone: model.phone,
      cpf: model.cpf,
      birthDate: model.birthDate,
      photoUrl: model.photoUrl,
      address: AddressDto.fromDomain(model.address),
    );
  }

  // DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'cpf': cpf,
      'birth_date': birthDate,
      'photo_url': photoUrl,
      'address': address.toJson(),
    };
  }

  // DTO → Model de domínio
  ProfileModel toDomain() {
    return ProfileModel(
      id: userId,
      name: fullName,
      email: email,
      phone: phone,
      cpf: cpf,
      birthDate: birthDate,
      photoUrl: photoUrl,
      address: address.toDomain(),
    );
  }
}
