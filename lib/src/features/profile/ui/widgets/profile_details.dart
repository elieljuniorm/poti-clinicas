import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_primary_button.dart';
import '../../domain/models/profile_model.dart';
import 'profile_field.dart';
import 'profile_header.dart';
import 'profile_section_card.dart';

/// Variação de visualização: os campos pessoais aparecem bloqueados
/// e o botão "EDITAR DADOS" leva para a variação de edição.
class ProfileDetails extends StatelessWidget {
  final ProfileModel perfil;
  final VoidCallback aoEditar;

  const ProfileDetails({
    super.key,
    required this.perfil,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileHeader(nome: perfil.name, fotoUrl: perfil.photoUrl),
        const SizedBox(height: 24),
        ProfileSectionCard(
          titulo: 'DADOS PESSOAIS',
          children: [
            ProfileField(
              rotulo: 'NOME',
              icon: Icons.person_outline,
              valorInicial: perfil.name,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'E-MAIL',
              icon: Icons.email_outlined,
              valorInicial: perfil.email,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'TELEFONE',
              icon: Icons.phone_outlined,
              valorInicial: perfil.phone,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'DATA DE NASCIMENTO',
              icon: Icons.cake_outlined,
              valorInicial: perfil.birthDate,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'CPF',
              icon: Icons.badge_outlined,
              valorInicial: perfil.cpf,
              habilitado: false,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: AppPrimaryButton(
            label: 'EDITAR CADASTRO',
            onPressed: aoEditar,
            width: 271,
          ),
        ),
      ],
    );
  }
}
