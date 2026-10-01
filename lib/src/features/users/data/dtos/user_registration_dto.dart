import '../../../../core/utils/documento.dart';
import '../../../profile/data/dtos/address_dto.dart';
import '../../domain/models/bank_info_model.dart';
import '../../domain/models/user_registration_model.dart';

/// Representa o cadastro exatamente como a API recebe.
/// Documento e telefone trafegam só com dígitos.
class UserRegistrationDto {
  final String name;
  final String email;
  final String phone;
  final String? birthDate;
  final String role;
  final String document;
  final String? councilNumber;
  final String? description;
  final String? patientCategory;
  final String? professionalId;
  final AddressDto? address;
  final Map<String, dynamic>? bankInfo;

  UserRegistrationDto({
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    required this.role,
    required this.document,
    this.councilNumber,
    this.description,
    this.patientCategory,
    this.professionalId,
    this.address,
    this.bankInfo,
  });

  // Model de domínio → DTO
  factory UserRegistrationDto.fromDomain(UserRegistrationModel model) {
    String? texto(String? valor) =>
        valor == null || valor.trim().isEmpty ? null : valor.trim();

    final address = model.address;
    return UserRegistrationDto(
      name: model.name,
      email: model.email,
      phone: Documento.digitos(model.phone),
      birthDate: texto(model.birthDate),
      // Os nomes do enum já são os valores da API.
      role: model.role.name,
      document: Documento.digitos(model.document),
      councilNumber: texto(model.councilNumber)?.toUpperCase(),
      description: texto(model.description),
      patientCategory: model.patientCategory?.name,
      professionalId: model.professionalId,
      address: address == null ? null : AddressDto.fromDomain(address),
      bankInfo: _bankInfoJson(model.bankInfo),
    );
  }

  /// Dados financeiros no formato da API. Agência e conta só com dígitos
  /// e traço; `null` quando nada foi informado.
  static Map<String, dynamic>? _bankInfoJson(BankInfoModel? info) {
    if (info == null) return null;

    String? texto(String? valor) =>
        valor == null || valor.trim().isEmpty ? null : valor.trim();

    final json = <String, dynamic>{
      'bank': ?texto(info.bank),
      'agency': ?texto(info.agency),
      'account': ?texto(info.account),
      'account_type': ?info.accountType?.name,
      'pix_key_type': ?info.pixKeyType?.name,
      'pix_key': ?texto(info.pixKey),
    };
    return json.isEmpty ? null : json;
  }

  // DTO → JSON (campos vazios não são enviados)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': ?birthDate,
      'role': role,
      'document': document,
      'council_number': ?councilNumber,
      'description': ?description,
      'patient_category': ?patientCategory,
      'professional_id': ?professionalId,
      'address': ?address?.toJson(),
      'bank_info': ?bankInfo,
    };
  }
}
