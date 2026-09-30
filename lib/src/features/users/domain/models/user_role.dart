/// Perfis de usuário do sistema.
/// As permissões de cada perfil serão definidas depois.
enum UserRole {
  professional('Profissional'),
  patient('Paciente'),
  admin('Administrador'),
  reception('Recepção'),
  collaborator('Colaborador');

  final String label;

  const UserRole(this.label);
}
