import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/auth/domain/models/user.dart';
import 'package:poti_5f/src/features/login/data/dtos/user_dto.dart';

void main() {
  test('fromJson + toDomain convertem os campos da API para User', () {
    final user = UserDto.fromJson({
      'user_id': '7',
      'full_name': 'Ana Souza',
      'email': 'ana@x.com',
      'access_token': 'tok',
      'photo_url': 'https://x/foto.png',
    }).toDomain();

    expect(
      user,
      const User(
        id: '7',
        name: 'Ana Souza',
        email: 'ana@x.com',
        token: 'tok',
        photoUrl: 'https://x/foto.png',
      ),
    );
  });

  test('photo_url é opcional', () {
    final user = UserDto.fromJson({
      'user_id': '7',
      'full_name': 'Ana Souza',
      'email': 'ana@x.com',
      'access_token': 'tok',
    }).toDomain();

    expect(user.photoUrl, isNull);
  });
}
