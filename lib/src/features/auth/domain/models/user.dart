/// Modelo de domínio do usuário logado.
///
/// Vive em `auth/` porque representa a sessão autenticada — não é
/// específico do fluxo de login. Qualquer feature que precise do usuário
/// logado importa daqui.
class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? photoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          token == other.token &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => Object.hash(id, name, email, token, photoUrl);
}