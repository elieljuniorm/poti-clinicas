/// Dados de acesso da equipe interna (administração, recepção, colaboradores).
class AccessInfoModel {
  final String area;
  final String since;
  final String lastAccess;

  const AccessInfoModel({
    required this.area,
    required this.since,
    required this.lastAccess,
  });
}
