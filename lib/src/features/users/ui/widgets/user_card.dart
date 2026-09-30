import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import 'user_avatar.dart';

/// Card de um usuário: perfil, descrição, status, foto, nome e contatos.
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserCard({super.key, required this.user, this.onTap});

  (Color texto, Color fundo) _getRoleColors(UserRole role) {
    switch (role) {
      case UserRole.professional:
        return (
          AppColors.roleProfessional,
          AppColors.roleProfessionalBackground,
        );
      case UserRole.patient:
        return (AppColors.rolePatient, AppColors.rolePatientBackground);
      case UserRole.admin:
        return (AppColors.roleAdmin, AppColors.roleAdminBackground);
      case UserRole.reception:
        return (AppColors.roleReception, AppColors.roleReceptionBackground);
      case UserRole.collaborator:
        return (
          AppColors.roleCollaborator,
          AppColors.roleCollaboratorBackground,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (corPerfil, fundoPerfil) = _getRoleColors(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Perfil • descrição ........ status
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    _Etiqueta(
                      texto: user.role.label,
                      cor: corPerfil,
                      fundo: fundoPerfil,
                    ),
                    if (user.detail != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '• ${user.detail}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    const SizedBox(width: 8),
                    user.active
                        ? const _Etiqueta(
                            texto: 'Ativo',
                            cor: AppColors.userActive,
                            fundo: AppColors.userActiveBackground,
                          )
                        : const _Etiqueta(
                            texto: 'Inativo',
                            cor: AppColors.userInactive,
                            fundo: AppColors.userInactiveBackground,
                          ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey[200],
              ),
              // Foto, nome e contatos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserAvatar(photoUrl: user.photoUrl),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _Contato(icon: Symbols.mail, texto: user.email),
                          const SizedBox(height: 2),
                          _Contato(icon: Symbols.call, texto: user.phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Etiqueta arredondada (perfil do usuário e status).
class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  final Color fundo;

  const _Etiqueta({
    required this.texto,
    required this.cor,
    required this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Contato extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Contato({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.borderAccent),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
