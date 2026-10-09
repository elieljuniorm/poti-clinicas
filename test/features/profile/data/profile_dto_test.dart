import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/profile/data/dtos/profile_dto.dart';
import 'package:multiclinica_app/src/features/profile/domain/models/address_model.dart';

void main() {
  final json = {
    'user_id': '1',
    'full_name': 'Ana Souza',
    'email': 'ana@x.com',
    'phone': '(86) 90000-0000',
    'cpf': '111.222.333-44',
    'birth_date': '01/02/1990',
    'photo_url': null,
    'address': {
      'zip_code': '64000-000',
      'street': 'Rua A',
      'number': '10',
      'complement': '',
      'neighborhood': 'Centro',
      'city': 'Teresina',
      'state': 'PI',
    },
  };

  test('fromJson + toDomain convertem perfil e endereço', () {
    final perfil = ProfileDto.fromJson(json).toDomain();

    expect(perfil.id, '1');
    expect(perfil.name, 'Ana Souza');
    expect(perfil.cpf, '111.222.333-44');
    expect(perfil.birthDate, '01/02/1990');
    expect(perfil.address.street, 'Rua A');
    expect(perfil.address.state, 'PI');
  });

  test('campos opcionais ausentes viram texto vazio', () {
    final perfil = ProfileDto.fromJson({
      'user_id': '1',
      'full_name': 'Ana',
      'email': 'ana@x.com',
    }).toDomain();

    expect(perfil.phone, '');
    expect(perfil.address.city, '');
    expect(perfil.photoUrl, isNull);
  });

  test('fromDomain + toJson devolvem o mesmo JSON (ida e volta)', () {
    final perfil = ProfileDto.fromJson(json).toDomain();

    expect(ProfileDto.fromDomain(perfil).toJson(), json);
  });

  test('CEP sai e chega sempre no formato 00000-000', () {
    final semTraco = {
      ...json,
      'address': <String, dynamic>{
        ...(json['address'] as Map<String, dynamic>),
        'zip_code': '64000000',
      },
    };
    final perfil = ProfileDto.fromJson(semTraco).toDomain();

    expect(perfil.address.zipCode, '64000-000');
    expect(
      (ProfileDto.fromDomain(perfil).toJson()['address'] as Map)['zip_code'],
      '64000-000',
    );
  });

  test('AddressModel.resumo ignora partes vazias', () {
    const endereco = AddressModel(
      street: 'Rua A',
      number: '10',
      neighborhood: 'Centro',
      city: 'Teresina',
      state: 'PI',
    );

    expect(endereco.resumo, 'Rua A, 10 • Centro - Teresina - PI');
    expect(const AddressModel().resumo, '');
  });
}
