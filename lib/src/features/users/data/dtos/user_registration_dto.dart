import '../../../../core/utils/documento.dart';
import '../../../profile/data/dtos/address_dto.dart';
import '../../domain/models/bank_info_model.dart';
import '../../domain/models/family_income.dart';
import '../../domain/models/marital_status.dart';
import '../../domain/models/patient_category.dart';
import '../../domain/models/patient_responsible_model.dart';
import '../../domain/models/user_registration_model.dart';
import '../../domain/models/user_role.dart';

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

  // JSON → DTO (cadastro completo, usado na edição)
  factory UserRegistrationDto.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return UserRegistrationDto(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      role: json['role'],
      document: json['document'] ?? '',
      councilNumber: json['council_number'],
      description: json['description'],
      patientCategory: json['patient_category'],
      professionalId: json['professional_id'],
      address: address == null ? null : AddressDto.fromJson(address),
      bankInfo: json['bank_info'],
      maritalStatus: json['marital_status'],
      familyIncome: json['family_income'],
      clinicalCase: json['clinical_case'],
      selfResponsible: json['self_responsible'],
      responsible: json['responsible'],
    );
  }

  // DTO → Model de domínio. Valores desconhecidos de enum viram `null`.
  UserRegistrationModel toDomain() {
    final bankInfo = this.bankInfo;
    final responsible = this.responsible;
    return UserRegistrationModel(
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate ?? '',
      role: UserRole.values.asNameMap()[role] ?? UserRole.patient,
      document: document,
      councilNumber: councilNumber,
      description: description,
      patientCategory: PatientCategory.values.asNameMap()[patientCategory],
      professionalId: professionalId,
      address: address?.toDomain(),
      bankInfo: bankInfo == null
          ? null
          : BankInfoModel(
              bank: bankInfo['bank'],
              agency: bankInfo['agency'],
              account: bankInfo['account'],
              accountType: AccountType.values
                  .asNameMap()[bankInfo['account_type']],
              pixKeyType: PixKeyType.values
                  .asNameMap()[bankInfo['pix_key_type']],
              pixKey: bankInfo['pix_key'],
            ),
      maritalStatus: MaritalStatus.values.asNameMap()[maritalStatus],
      familyIncome: FamilyIncome.values.asNameMap()[familyIncome],
      clinicalCase: clinicalCase,
      selfResponsible: selfResponsible ?? false,
      responsible: responsible == null
          ? null
          : PatientResponsibleModel(
              name: responsible['name'] ?? '',
              email: responsible['email'] ?? '',
              phone: responsible['phone'] ?? '',
              birthDate: responsible['birth_date'] ?? '',
            ),
    );
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
