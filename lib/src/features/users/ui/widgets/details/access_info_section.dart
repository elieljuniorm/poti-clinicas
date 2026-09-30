import 'package:flutter/material.dart';

import '../../../domain/models/access_info_model.dart';
import '../../../domain/models/user_model.dart';
import 'details_section.dart';

/// "DADOS DE ACESSO" da equipe interna (administração, recepção, colaborador).
class AccessInfoSection extends StatelessWidget {
  final UserModel user;
  final AccessInfoModel info;

  const AccessInfoSection({super.key, required this.user, required this.info});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      titulo: 'DADOS DE ACESSO',
      child: DetailsPanel(
        child: Column(
          children: [
            DetailsRow(rotulo: 'Perfil', valor: user.role.label),
            DetailsRow(rotulo: 'Setor', valor: info.area),
            DetailsRow(rotulo: 'Na clínica desde', valor: info.since),
            DetailsRow(rotulo: 'Último acesso', valor: info.lastAccess),
          ],
        ),
      ),
    );
  }
}
