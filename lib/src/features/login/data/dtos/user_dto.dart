import '../../../auth/domain/models/user.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o `User` do domínio.
class UserDto {
  final String userId;
  final String fullName;
  final String email;
  final String accessToken;
  final String? photoUrl;

  UserDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.accessToken,
    this.photoUrl,
  });

  // JSON → DTO
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      accessToken: json['access_token'],
      photoUrl: json['photo_url'],
    );
  }

  // DTO → Model de domínio (User de auth/)
  User toDomain() {
    return User(
      id: userId,
      name: fullName,
      email: email,
      token: accessToken,
      photoUrl: photoUrl,
    );
  }
}