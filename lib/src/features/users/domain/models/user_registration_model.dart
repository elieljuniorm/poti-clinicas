import '../../../profile/domain/models/address_model.dart';
import 'bank_info_model.dart';
import 'patient_category.dart';
import 'user_role.dart';

/// Dados de um usuário novo, cadastrado pela clínica.
///
/// - Profissional de saúde, administrador, recepção e colaborador:
///   [document] é CPF ou CNPJ; [councilNumber] só para profissional de saúde;
///   [address] sem mapa e [bankInfo] (dados financeiros, opcionais).
/// - Paciente: [document] é CPF, com [patientCategory], [professionalId]
///   (profissional responsável) e [address].
class UserRegistrationModel {
  final String name;
  final String email;
  final String phone;

  /// `DD/MM/AAAA`. Vazia quando não informada.
  final String birthDate;
  final UserRole role;
  final String document;

  /// Número de inscrição no conselho (ex.: CREFITO).
  final String? councilNumber;

  /// Especialidade do profissional ou setor da equipe interna.
  final String? description;
  final PatientCategory? patientCategory;
  final String? professionalId;
  final AddressModel? address;
  final BankInfoModel? bankInfo;

  const UserRegistrationModel({
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate = '',
    required this.role,
    required this.document,
    this.councilNumber,
    this.description,
    this.patientCategory,
    this.professionalId,
    this.address,
    this.bankInfo,
  });
}
