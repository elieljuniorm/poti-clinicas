import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
              icon: Symbols.person,
              valorInicial: perfil.name,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'E-MAIL',
              icon: Symbols.mail,
              valorInicial: perfil.email,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'TELEFONE',
              icon: Symbols.call,
              valorInicial: perfil.phone,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'DATA DE NASCIMENTO',
              icon: Symbols.cake,
              valorInicial: perfil.birthDate,
              habilitado: false,
            ),
            ProfileField(
              rotulo: 'CPF',
              icon: Symbols.badge,
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
