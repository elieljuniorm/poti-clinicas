import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dtos/nominatim_place_dto.dart';

/// Responsabilidade: consultar o Nominatim (geocodificação do OpenStreetMap).
///
/// A política de uso do serviço público pede no máximo 1 requisição por
/// segundo e um User-Agent que identifique o app:
/// https://operations.osmfoundation.org/policies/nominatim/
class GeocodingDataSource {
  static const _host = 'nominatim.openstreetmap.org';
  static const _intervaloMinimo = Duration(seconds: 1);

  // No navegador o User-Agent é bloqueado; lá o próprio browser se identifica.
  static const _ehWeb = bool.fromEnvironment('dart.library.js_interop');

  /// Só ASCII: o `dart:io` recusa cabeçalhos com acento.
  static const userAgent = 'poti_5f/1.0 (app Poti Clinicas)';

  final http.Client _client;
  DateTime? _ultimaRequisicao;

  GeocodingDataSource(this._client);

  Future<List<NominatimPlaceDto>> buscar(String consulta) async {
    final json = await _get('/search', {
      'q': consulta,
      'countrycodes': 'br',
      'limit': '1',
    });
    return (json as List)
        .map((item) => NominatimPlaceDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca só pelo CEP: devolve a região dele.
  Future<List<NominatimPlaceDto>> buscarPorCep(String cep) async {
    final json = await _get('/search', {
      'postalcode': cep,
      'country': 'Brasil',
      'limit': '1',
    });
    return (json as List)
        .map((item) => NominatimPlaceDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<NominatimPlaceDto?> buscarReverso(double lat, double lon) async {
    final json = await _get('/reverse', {
      'lat': '$lat',
      'lon': '$lon',
      'zoom': '18', // nível de rua/número
    });
    // Sem resultado, o Nominatim devolve {"error": "Unable to geocode"}.
    if (json is! Map<String, dynamic> || json.containsKey('error')) return null;
    return NominatimPlaceDto.fromJson(json);
  }

  Future<dynamic> _get(String path, Map<String, String> params) async {
    await _respeitarIntervalo();

    final uri = Uri.https(_host, path, {
      ...params,
      'format': 'jsonv2',
      'addressdetails': '1',
    });
    final resposta = await _client.get(
      uri,
      headers: {
        'Accept-Language': 'pt-BR',
        if (!_ehWeb) 'User-Agent': userAgent,
      },
    );

    if (resposta.statusCode != 200) {
      throw Exception('Falha na busca de endereço (${resposta.statusCode})');
    }
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  Future<void> _respeitarIntervalo() async {
    final ultima = _ultimaRequisicao;
    if (ultima != null) {
      final espera = _intervaloMinimo - DateTime.now().difference(ultima);
      if (espera > Duration.zero) await Future.delayed(espera);
    }
    _ultimaRequisicao = DateTime.now();
  }
}
