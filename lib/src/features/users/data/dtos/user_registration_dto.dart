import '../../../../core/utils/documento.dart';
import '../../../profile/data/dtos/address_dto.dart';
import '../../domain/models/bank_info_model.dart';
import '../../domain/models/patient_responsible_model.dart';
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
  final String? maritalStatus;
  final String? familyIncome;
  final String? clinicalCase;
  final bool? selfResponsible;
  final Map<String, dynamic>? responsible;

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
    this.maritalStatus,
    this.familyIncome,
    this.clinicalCase,
    this.selfResponsible,
    this.responsible,
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
      maritalStatus: model.maritalStatus?.name,
      familyIncome: model.familyIncome?.name,
      clinicalCase: texto(model.clinicalCase),
      // Só o cadastro de paciente tem responsável.
      selfResponsible: model.responsible == null ? null : model.selfResponsible,
      responsible: _responsibleJson(model.responsible),
    );
  }

  /// Responsável no formato da API, com telefone só com dígitos.
  static Map<String, dynamic>? _responsibleJson(
    PatientResponsibleModel? responsavel,
  ) {
    if (responsavel == null) return null;
    final nascimento = responsavel.birthDate.trim();
    return {
      'name': responsavel.name.trim(),
      'email': responsavel.email.trim(),
      'phone': Documento.digitos(responsavel.phone),
      'birth_date': ?(nascimento.isEmpty ? null : nascimento),
    };
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
      'marital_status': ?maritalStatus,
      'family_income': ?familyIncome,
      'clinical_case': ?clinicalCase,
      'self_responsible': ?selfResponsible,
      'responsible': ?responsible,
    };
  }
}
