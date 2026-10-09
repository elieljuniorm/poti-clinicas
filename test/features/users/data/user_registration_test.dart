import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/profile/domain/models/address_model.dart';
import 'package:multiclinica_app/src/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:multiclinica_app/src/features/users/data/dtos/user_registration_dto.dart';
import 'package:multiclinica_app/src/features/users/domain/models/bank_info_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/patient_category.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_registration_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_role.dart';

void main() {
  const paciente = UserRegistrationModel(
    name: 'Maria Souza',
    email: 'maria@gmail.com',
    phone: '(91) 9 9999-8888',
    birthDate: '15/03/1990',
    role: UserRole.patient,
    document: '529.982.247-25',
    patientCategory: PatientCategory.adult,
    professionalId: '1',
    address: AddressModel(
      zipCode: '66017000',
      street: 'Rua A',
      number: '10',
      neighborhood: 'Centro',
      city: 'Belém',
      state: 'PA',
    ),
  );

  group('UserRegistrationDto', () {
    test(
      'paciente: documento e telefone só com dígitos, categoria e endereço',
      () {
        final json = UserRegistrationDto.fromDomain(paciente).toJson();

        expect(json['role'], 'patient');
        expect(json['phone'], '91999998888');
        expect(json['document'], '52998224725');
        expect(json['patient_category'], 'adult');
        expect(json['professional_id'], '1');
        expect(json['address']['zip_code'], '66017-000');
        expect(json.containsKey('council_number'), isFalse);
      },
    );

    test('profissional: conselho em maiúsculas e vazios não são enviados', () {
      final json = UserRegistrationDto.fromDomain(
        const UserRegistrationModel(
          name: 'Ana',
          email: 'ana@5f.com',
          phone: '(91) 9 9999-8888',
          role: UserRole.professional,
          document: '11.222.333/0001-81',
          councilNumber: '123456-f',
          description: '  ',
        ),
      ).toJson();

      expect(json['role'], 'professional');
      expect(json['document'], '11222333000181');
      expect(json['council_number'], '123456-F');
      expect(json.containsKey('birth_date'), isFalse);
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('address'), isFalse);
      expect(json.containsKey('bank_info'), isFalse);
    });

    test('dados financeiros: valores da API e partes vazias de fora', () {
      final json = UserRegistrationDto.fromDomain(
        const UserRegistrationModel(
          name: 'Ana',
          email: 'ana@5f.com',
          phone: '91999998888',
          role: UserRole.collaborator,
          document: '52998224725',
          bankInfo: BankInfoModel(
            bank: '',
            agency: '',
            account: '',
            pixKeyType: PixKeyType.email,
            pixKey: ' ana@5f.com ',
          ),
        ),
      ).toJson();

      expect(json['bank_info'], {
        'pix_key_type': 'email',
        'pix_key': 'ana@5f.com',
      });
    });
  });

  group('UsersDataSource.cadastrarUsuario', () {
    test(
      'o cadastrado aparece na lista, ativo e com telefone formatado',
      () async {
        final dataSource = UsersDataSource();

        final novo = await dataSource.cadastrarUsuario(
          UserRegistrationDto.fromDomain(paciente),
        );
        final lista = await dataSource.buscarUsuarios();

        final model = novo.toDomain();
        expect(model.active, isTrue);
        expect(model.patientCategory, PatientCategory.adult);
        expect(model.phone, '(91) 9 9999-8888');
        expect(lista.map((u) => u.email), contains('maria@gmail.com'));
      },
    );

    test('recusa e-mail já cadastrado (sem diferenciar maiúsculas)', () async {
      final dataSource = UsersDataSource();

      expect(
        () => dataSource.cadastrarUsuario(
          UserRegistrationDto.fromDomain(
            const UserRegistrationModel(
              name: 'Outro',
              email: 'ARNALDO.RIBEIRO@5f.com',
              phone: '91999998888',
              role: UserRole.professional,
              document: '52998224725',
            ),
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => '$e',
            'mensagem',
            contains('Já existe um usuário com este e-mail'),
          ),
        ),
      );
    });
  });
}
