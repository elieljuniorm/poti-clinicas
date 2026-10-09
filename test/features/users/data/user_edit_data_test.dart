import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:multiclinica_app/src/features/users/data/dtos/user_registration_dto.dart';
import 'package:multiclinica_app/src/features/users/data/repository/users_repository_impl.dart';
import 'package:multiclinica_app/src/features/users/domain/models/bank_info_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/family_income.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_registration_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_role.dart';

void main() {
  group('UserRegistrationDto.fromJson', () {
    test('lê o cadastro completo e volta ao mesmo JSON', () {
      final json = {
        'name': 'Ana Lima',
        'email': 'ana@5f.com',
        'phone': '91999998888',
        'birth_date': '01/10/1998',
        'role': 'professional',
        'document': '52998224725',
        'council_number': '000000-F',
        'description': 'Fisioterapeuta',
        'address': {
          'zip_code': '66017-000',
          'street': 'Rua A',
          'number': '10',
          'complement': '',
          'neighborhood': 'Centro',
          'city': 'Belém',
          'state': 'PA',
        },
        'bank_info': {
          'bank': '001',
          'agency': '0000-0',
          'account': '00000000-0',
          'account_type': 'checking',
          'pix_key_type': 'random',
          'pix_key': 'Chave#0000',
        },
      };

      final model = UserRegistrationDto.fromJson(json).toDomain();
      expect(model.role, UserRole.professional);
      expect(model.councilNumber, '000000-F');
      expect(model.address!.city, 'Belém');
      expect(model.bankInfo!.accountType, AccountType.checking);
      expect(model.bankInfo!.pixKeyType, PixKeyType.random);

      expect(UserRegistrationDto.fromDomain(model).toJson(), json);
    });

    test('valores desconhecidos de enum viram null', () {
      final model = UserRegistrationDto.fromJson({
        'name': 'Maria',
        'email': 'maria@gmail.com',
        'phone': '91999998888',
        'role': 'patient',
        'family_income': 'valor-novo',
      }).toDomain();

      expect(model.familyIncome, isNull);
      expect(model.document, '');
      expect(model.birthDate, '');
    });
  });

  group('edição no data source', () {
    late UsersRepositoryImpl repository;

    setUp(() => repository = UsersRepositoryImpl(UsersDataSource()));

    test('busca o cadastro completo de um usuário de exemplo', () async {
      final dados = await repository.buscarCadastro('2');

      expect(dados.user.name, 'Juliana Mendes Souza');
      expect(dados.cadastro.role, UserRole.patient);
      expect(dados.cadastro.familyIncome, FamilyIncome.from7000To22000);
      expect(dados.cadastro.selfResponsible, isFalse);
      expect(dados.cadastro.responsible!.name, 'Luiz Marques Pontes');
    });

    test('sem cadastro completo, usa os dados da lista', () async {
      final dados = await repository.buscarCadastro('5');

      expect(dados.cadastro.name, 'Fernanda Lima');
      expect(dados.cadastro.phone, '91987654321');
      expect(dados.cadastro.role, UserRole.reception);
    });

    test('atualizar muda a lista e o cadastro', () async {
      await repository.atualizarUsuario(
        '5',
        const UserRegistrationModel(
          name: 'Fernanda Lima Costa',
          email: 'fernanda.costa@5f.com',
          phone: '(91) 9 1111-2222',
          role: UserRole.collaborator,
          document: '529.982.247-25',
          description: 'Financeiro',
        ),
      );

      final usuario = (await repository.buscarUsuarios()).firstWhere(
        (u) => u.id == '5',
      );
      expect(usuario.name, 'Fernanda Lima Costa');
      expect(usuario.phone, '(91) 9 1111-2222');
      expect(usuario.role, UserRole.collaborator);

      final dados = await repository.buscarCadastro('5');
      expect(dados.cadastro.description, 'Financeiro');
      expect(dados.cadastro.document, '52998224725');
    });

    test(
      'atualizar recusa o e-mail de outro usuário, mas aceita o próprio',
      () {
        UserRegistrationModel comEmail(String email) => UserRegistrationModel(
          name: 'Fernanda Lima',
          email: email,
          phone: '(91) 9 8765-4321',
          role: UserRole.reception,
          document: '',
        );

        expect(
          repository.atualizarUsuario('5', comEmail('arnaldo.ribeiro@5f.com')),
          throwsA(isA<Exception>()),
        );
        expect(
          repository.atualizarUsuario('5', comEmail('fernanda.lima@5f.com')),
          completes,
        );
      },
    );

    test('desativar e ativar mudam o status na lista', () async {
      final desativado = await repository.alterarStatus('1', ativo: false);
      expect(desativado.active, isFalse);

      final usuarios = await repository.buscarUsuarios();
      expect(usuarios.firstWhere((u) => u.id == '1').active, isFalse);

      final ativado = await repository.alterarStatus('1', ativo: true);
      expect(ativado.active, isTrue);
    });

    test('usuário inexistente é recusado', () {
      expect(repository.resetarSenha('nao-existe'), throwsA(isA<Exception>()));
    });
  });
}
