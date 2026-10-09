import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:multiclinica_app/src/features/profile/data/data_sources/geocoding_remote_data_source.dart';
import 'package:multiclinica_app/src/features/profile/data/dtos/nominatim_place_dto.dart';
import 'package:multiclinica_app/src/features/profile/data/repository/geocoding_repository_impl.dart';
import 'package:multiclinica_app/src/features/profile/domain/models/address_model.dart';
import 'package:multiclinica_app/src/features/profile/domain/models/geo_point_model.dart';

void main() {
  final lugar = {
    'lat': '-1.4521',
    'lon': '-48.4867',
    'address': {
      'road': 'Avenida Presidente Vargas',
      'house_number': '640',
      'suburb': 'Campina',
      'city': 'Belém',
      'ISO3166-2-lvl4': 'BR-PA',
      'postcode': '66017-000',
    },
  };

  group('NominatimPlaceDto', () {
    test('converte coordenadas e endereço, com UF pela sigla ISO', () {
      final dto = NominatimPlaceDto.fromJson(lugar);

      expect(
        dto.toGeoPoint(),
        const GeoPointModel(latitude: -1.4521, longitude: -48.4867),
      );
      expect(
        dto.toAddress(),
        const AddressModel(
          zipCode: '66017-000',
          street: 'Avenida Presidente Vargas',
          number: '640',
          neighborhood: 'Campina',
          city: 'Belém',
          state: 'PA',
        ),
      );
    });

    test('usa town quando não há city e aceita endereço vazio', () {
      final dto = NominatimPlaceDto.fromJson({
        'lat': '0',
        'lon': '0',
        'address': {'town': 'Ananindeua'},
      });
      expect(dto.city, 'Ananindeua');
      expect(dto.stateCode, '');
      expect(dto.road, '');
    });
  });

  group('GeocodingRepositoryImpl', () {
    const endereco = AddressModel(
      zipCode: '66017000',
      street: 'Rua Inexistente',
      number: '10',
      complement: 'Sala 2',
      neighborhood: 'Bairro X',
      city: 'Belém',
      state: 'PA',
    );

    test('consulta sem número e complemento, do completo ao simples', () async {
      final consultas = <String>[];
      final client = MockClient((request) async {
        consultas.add(request.url.queryParameters['q']!);
        // Só a segunda consulta (sem número e bairro) encontra.
        final body = consultas.length == 1 ? [] : [lugar];
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      });
      final repository = GeocodingRepositoryImpl(GeocodingDataSource(client));

      final ponto = await repository.buscarCoordenadas(endereco);

      expect(consultas, [
        'Rua Inexistente, 66017-000, Bairro X, Belém, PA, Brasil',
        'Rua Inexistente, Belém, PA, Brasil',
      ]);
      expect(ponto?.latitude, -1.4521);
    });

    test('rua não encontrada: tenta a região do CEP', () async {
      final requisicoes = <Map<String, String>>[];
      final client = MockClient((request) async {
        requisicoes.add(request.url.queryParameters);
        final body = requisicoes.length < 3 ? [] : [lugar];
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      });
      final repository = GeocodingRepositoryImpl(GeocodingDataSource(client));

      final ponto = await repository.buscarCoordenadas(endereco);

      expect(requisicoes, hasLength(3));
      expect(requisicoes.last['postalcode'], '66017-000');
      expect(ponto, isNotNull);
    });

    test('sem rua e sem CEP não consulta o serviço', () async {
      var chamadas = 0;
      final client = MockClient((_) async {
        chamadas++;
        return http.Response('[]', 200);
      });
      final repository = GeocodingRepositoryImpl(GeocodingDataSource(client));

      final ponto = await repository.buscarCoordenadas(
        const AddressModel(city: 'Belém'),
      );

      expect(ponto, isNull);
      expect(chamadas, 0);
    });

    test('reverso sem resultado devolve null', () async {
      final client = MockClient(
        (_) async => http.Response('{"error":"Unable to geocode"}', 200),
      );
      final repository = GeocodingRepositoryImpl(GeocodingDataSource(client));

      final resultado = await repository.buscarEndereco(
        const GeoPointModel(latitude: 0, longitude: 0),
      );
      expect(resultado, isNull);
    });

    test('User-Agent só com ASCII (o dart:io recusa acentos)', () {
      expect(
        RegExp(r'^[\x20-\x7E]+$').hasMatch(GeocodingDataSource.userAgent),
        isTrue,
      );
    });

    test('status diferente de 200 vira exceção', () async {
      final client = MockClient((_) async => http.Response('', 429));
      final repository = GeocodingRepositoryImpl(GeocodingDataSource(client));

      expect(repository.buscarCoordenadas(endereco), throwsException);
    });
  });
}
