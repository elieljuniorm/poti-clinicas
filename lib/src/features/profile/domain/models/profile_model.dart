import 'address_model.dart';

/// Dados cadastrais completos do usuário logado.
///
/// Diferente do [User] de `auth/`, que guarda só o necessário para a sessão.
class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String cpf;
  final String birthDate;
  final String? photoUrl;
  final AddressModel address;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.cpf = '',
    this.birthDate = '',
    this.photoUrl,
    this.address = const AddressModel(),
  });

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    AddressModel? address,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl,
      address: address ?? this.address,
    );
  }
}
