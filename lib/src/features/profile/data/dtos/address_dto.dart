import '../../domain/models/address_model.dart';

/// Representa o endereço exatamente como a API envia
/// e sabe se converter para o model do domínio (e voltar).
class AddressDto {
  final String zipCode;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;

  AddressDto({
    required this.zipCode,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  // JSON → DTO (campos ausentes viram texto vazio)
  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      zipCode: json['zip_code'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      complement: json['complement'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }

  // Model de domínio → DTO (usado ao salvar)
  factory AddressDto.fromDomain(AddressModel model) {
    return AddressDto(
      zipCode: model.zipCode,
      street: model.street,
      number: model.number,
      complement: model.complement,
      neighborhood: model.neighborhood,
      city: model.city,
      state: model.state,
    );
  }

  // DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'zip_code': zipCode,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
    };
  }

  // DTO → Model de domínio
  AddressModel toDomain() {
    return AddressModel(
      zipCode: zipCode,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      state: state,
    );
  }
}
