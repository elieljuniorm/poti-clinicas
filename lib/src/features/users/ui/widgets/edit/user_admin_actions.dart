import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../states/user_edit_state.dart';

/// Área "ADMINISTRAR USUÁRIO" da edição: ativar/desativar o acesso e
/// resetar a senha.
///
/// Com uma ação em andamento ([emAndamento]), o botão dela mostra o
/// indicador e os dois ficam bloqueados.
class UserAdminActions extends StatelessWidget {
  final bool ativo;
  final UserEditAction? emAndamento;
  final VoidCallback aoAlternarStatus;
  final VoidCallback aoResetarSenha;

  const UserAdminActions({
    super.key,
    required this.ativo,
    required this.aoAlternarStatus,
    required this.aoResetarSenha,
    this.emAndamento,
  });

  @override
  Widget build(BuildContext context) {
    final ocupado = emAndamento != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ADMINISTRAR USUÁRIO', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ativo
                    ? _AdminButton(
                        label: 'Desativar Usuário',
                        icon: Symbols.no_accounts,
                        cor: AppColors.userDeactivate,
                        corFundo: AppColors.userDeactivateBackground,
                        carregando: emAndamento == UserEditAction.alterarStatus,
                        onPressed: ocupado ? null : aoAlternarStatus,
                      )
                    : _AdminButton(
                        label: 'Ativar Usuário',
                        icon: Symbols.account_circle,
                        cor: AppColors.userActivate,
                        corFundo: AppColors.userActivateBackground,
                        carregando: emAndamento == UserEditAction.alterarStatus,
                        onPressed: ocupado ? null : aoAlternarStatus,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminButton(
                  label: 'Resetar Senha',
                  icon: Symbols.lock_reset,
                  cor: AppColors.userResetPassword,
                  corFundo: AppColors.userResetPasswordBackground,
                  carregando: emAndamento == UserEditAction.resetarSenha,
                  onPressed: ocupado ? null : aoResetarSenha,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Botão em pílula com contorno, ícone e texto na mesma cor.
class _AdminButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color cor;
  final Color corFundo;
  final bool carregando;
  final VoidCallback? onPressed;

  const _AdminButton({
    required this.label,
    required this.icon,
    required this.cor,
    required this.corFundo,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: corFundo,
          foregroundColor: cor,
          disabledForegroundColor: cor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(
            color: onPressed == null && !carregando
                ? cor.withValues(alpha: 0.5)
                : cor,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
        ),
        child: carregando
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: cor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
