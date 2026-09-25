import '../../../../core/utils/cep.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/geo_point_model.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../data_sources/geocoding_remote_data_source.dart';

/// Responsabilidade: montar as consultas a partir do endereço
/// e converter os resultados (DTO) em models.
class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingDataSource _dataSource;

  GeocodingRepositoryImpl(this._dataSource);

  /// Localiza pela rua, CEP, bairro e cidade/UF.
  /// Número e complemento não entram: não mudam o local no mapa.
  @override
  Future<GeoPointModel?> buscarCoordenadas(AddressModel endereco) async {
    final temRua =
        endereco.street.trim().isNotEmpty && endereco.city.trim().isNotEmpty;
    final cep = Cep.formatar(endereco.zipCode);

    if (temRua) {
      // Da consulta mais completa para a mais simples: o nome do bairro
      // no OpenStreetMap nem sempre é igual ao dos Correios.
      final tentativas = {
        _consulta([
          endereco.street,
          ?cep,
          endereco.neighborhood,
          endereco.city,
          endereco.state,
        ]),
        _consulta([endereco.street, endereco.city, endereco.state]),
      };

      for (final consulta in tentativas) {
        final resultados = await _dataSource.buscar(consulta);
        if (resultados.isNotEmpty) return resultados.first.toGeoPoint();
      }
    }

    // Rua não encontrada (ou vazia): tenta ao menos a região do CEP.
    if (cep != null) {
      final resultados = await _dataSource.buscarPorCep(cep);
      if (resultados.isNotEmpty) return resultados.first.toGeoPoint();
    }
    return null;
  }

  @override
  Future<AddressModel?> buscarEndereco(GeoPointModel ponto) async {
    final dto = await _dataSource.buscarReverso(
      ponto.latitude,
      ponto.longitude,
    );
    return dto?.toAddress();
  }

  String _consulta(List<String> partes) {
    return [
      ...partes.map((p) => p.trim()).where((p) => p.isNotEmpty),
      'Brasil',
    ].join(', ');
  }
}
