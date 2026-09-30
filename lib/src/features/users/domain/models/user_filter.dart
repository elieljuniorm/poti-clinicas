import 'user_role.dart';

/// Filtro da lista de usuários (seletor Todos / Profissionais / Pacientes).
enum UserFilter {
  all('Todos'),
  professionals('Profissionais'),
  patients('Pacientes');

  final String label;

  const UserFilter(this.label);

  bool aceita(UserRole role) {
    return switch (this) {
      UserFilter.all => true,
      UserFilter.professionals => role == UserRole.professional,
      UserFilter.patients => role == UserRole.patient,
    };
  }
}
