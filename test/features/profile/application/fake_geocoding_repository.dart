import 'package:poti_5f/src/features/profile/domain/models/address_model.dart';
import 'package:poti_5f/src/features/profile/domain/models/geo_point_model.dart';
import 'package:poti_5f/src/features/profile/domain/repositories/geocoding_repository.dart';

/// Geocodificação em memória: não acessa a rede.
class FakeGeocodingRepository implements GeocodingRepository {
  GeoPointModel? pontoEncontrado = const GeoPointModel(
    latitude: -5.09,
    longitude: -42.8,
  );
  AddressModel? enderecoDoPonto = const AddressModel(
    street: 'Avenida Frei Serafim',
    number: '2000',
    neighborhood: 'Centro',
    city: 'Teresina',
    state: 'PI',
  );
  bool deveFalhar = false;
  final buscas = <AddressModel>[];

  @override
  Future<GeoPointModel?> buscarCoordenadas(AddressModel endereco) async {
    buscas.add(endereco);
    if (deveFalhar) throw Exception('sem rede');
    return pontoEncontrado;
  }

  @override
  Future<AddressModel?> buscarEndereco(GeoPointModel ponto) async {
    if (deveFalhar) throw Exception('sem rede');
    return enderecoDoPonto;
  }
}
