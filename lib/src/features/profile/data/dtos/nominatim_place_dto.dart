import '../../../../core/utils/cep.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/geo_point_model.dart';

/// Um resultado do Nominatim (OpenStreetMap), com `addressdetails=1`.
class NominatimPlaceDto {
  final double lat;
  final double lon;
  final String road;
  final String houseNumber;
  final String neighborhood;
  final String city;
  final String stateCode;
  final String postcode;

  NominatimPlaceDto({
    required this.lat,
    required this.lon,
    this.road = '',
    this.houseNumber = '',
    this.neighborhood = '',
    this.city = '',
    this.stateCode = '',
    this.postcode = '',
  });

  // JSON → DTO
  factory NominatimPlaceDto.fromJson(Map<String, dynamic> json) {
    final address = (json['address'] as Map<String, dynamic>?) ?? const {};

    String primeiro(List<String> chaves) {
      for (final chave in chaves) {
        final valor = address[chave];
        if (valor is String && valor.isNotEmpty) return valor;
      }
      return '';
    }

    // "BR-PA" → "PA"
    final iso = primeiro(['ISO3166-2-lvl4']);

    return NominatimPlaceDto(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      road: primeiro(['road', 'pedestrian', 'footway']),
      houseNumber: primeiro(['house_number']),
      neighborhood: primeiro([
        'suburb',
        'neighbourhood',
        'quarter',
        'city_district',
      ]),
      city: primeiro(['city', 'town', 'village', 'municipality']),
      stateCode: iso.startsWith('BR-') ? iso.substring(3) : '',
      postcode: primeiro(['postcode']),
    );
  }

  // DTO → Models de domínio
  GeoPointModel toGeoPoint() => GeoPointModel(latitude: lat, longitude: lon);

  AddressModel toAddress() {
    return AddressModel(
      // O OSM pode trazer "66017000" ou CEP incompleto: só aceita o completo.
      zipCode: Cep.formatar(postcode) ?? '',
      street: road,
      number: houseNumber,
      neighborhood: neighborhood,
      city: city,
      state: stateCode,
    );
  }
}
