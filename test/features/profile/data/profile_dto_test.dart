import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/profile/data/dtos/profile_dto.dart';
import 'package:poti_5f/src/features/profile/domain/models/address_model.dart';

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
