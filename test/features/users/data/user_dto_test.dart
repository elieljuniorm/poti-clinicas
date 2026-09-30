import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/data/dtos/user_dto.dart';
import 'package:poti_5f/src/features/users/domain/models/user_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';

void main() {
  group('UserDto', () {
    UserModel converter({String role = 'professional', String? status}) {
      return UserDto.fromJson({
        'id': '1',
        'name': 'Dr. Arnaldo Ribeiro',
        'email': 'arnaldo@5f.com',
        'phone': '(91) 9 8455-1212',
        'role': role,
        'description': 'Fisioterapeuta',
        'status': status ?? 'active',
        'photo_url': null,
      }).toDomain();
    }

    test('converte os campos', () {
      final model = converter();

      expect(model.id, '1');
      expect(model.name, 'Dr. Arnaldo Ribeiro');
      expect(model.email, 'arnaldo@5f.com');
      expect(model.phone, '(91) 9 8455-1212');
      expect(model.description, 'Fisioterapeuta');
      expect(model.photoUrl, isNull);
    });

    test('mapeia os perfis, com patient como padrão', () {
      expect(converter(role: 'professional').role, UserRole.professional);
      expect(converter(role: 'patient').role, UserRole.patient);
      expect(converter(role: 'admin').role, UserRole.admin);
      expect(converter(role: 'reception').role, UserRole.reception);
      expect(converter(role: 'collaborator').role, UserRole.collaborator);
      expect(converter(role: 'desconhecido').role, UserRole.patient);
    });

    test('mapeia o status ativo/inativo', () {
      expect(converter(status: 'active').active, isTrue);
      expect(converter(status: 'inactive').active, isFalse);
    });
  });
}
