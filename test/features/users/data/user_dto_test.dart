import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/data/dtos/user_dto.dart';
import 'package:poti_5f/src/features/users/domain/models/patient_category.dart';
import 'package:poti_5f/src/features/users/domain/models/user_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';

void main() {
  group('UserDto', () {
    UserModel converter({String role = 'professional', String? status}) {
      return UserDto.fromJson({
        'id': '1',
        'name': 'Arnaldo Ribeiro',
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
      expect(model.name, 'Arnaldo Ribeiro');
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

    UserModel paciente(String? categoria) {
      return UserDto.fromJson({
        'id': '2',
        'name': 'Juliana',
        'email': 'juliana@gmail.com',
        'phone': '(91) 9 9211-4566',
        'role': 'patient',
        'patient_category': categoria,
        'status': 'active',
      }).toDomain();
    }

    test('mapeia a categoria do paciente', () {
      expect(paciente('pediatric').patientCategory, PatientCategory.pediatric);
      expect(paciente('adult').patientCategory, PatientCategory.adult);
      expect(paciente('elderly').patientCategory, PatientCategory.elderly);
      expect(paciente('desconhecida').patientCategory, isNull);
      expect(paciente(null).patientCategory, isNull);
    });

    test(
      'detalhe do card: categoria para paciente, descrição para os demais',
      () {
        expect(paciente('elderly').detail, 'Idoso');
        expect(converter().detail, 'Fisioterapeuta');
      },
    );
  });
}
