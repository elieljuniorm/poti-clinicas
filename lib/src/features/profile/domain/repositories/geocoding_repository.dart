import '../models/address_model.dart';
import '../models/geo_point_model.dart';

/// Contrato da busca de endereços no mapa.
abstract class GeocodingRepository {
  /// Endereço digitado → ponto no mapa. `null` quando não encontra.
  Future<GeoPointModel?> buscarCoordenadas(AddressModel endereco);

  /// Ponto tocado no mapa → endereço. `null` quando não encontra.
  Future<AddressModel?> buscarEndereco(GeoPointModel ponto);
}
