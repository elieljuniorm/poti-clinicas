import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_avatar.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/user_edit_controller.dart';
import '../../domain/models/user_edit_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import '../states/user_edit_state.dart';
import '../widgets/edit/user_admin_actions.dart';
import '../widgets/registration/patient_registration_form.dart';
import '../widgets/registration/professional_registration_form.dart';

/// Tela "Editar Usuário", aberta pelo card do topo do modal do usuário.
///
/// Usa o mesmo formulário do cadastro (paciente ou equipe, conforme o
/// perfil), já preenchido, e permite ativar/desativar o usuário e
/// resetar a senha.
class UserEditScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserEditScreen({super.key, required this.userId});

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  // Com o dedo no mapa, a página para de rolar e o arraste move o mapa.
  bool _usandoMapa = false;

  void _aoUsarMapa(bool usando) {
    if (usando != _usandoMapa) setState(() => _usandoMapa = usando);
  }

  void _voltar() => context.goNamed('usuario');

  UserEditController get _controller =>
      ref.read(userEditControllerProvider(widget.userId).notifier);

  Future<void> _alternarStatus(UserModel user) async {
    // Desativar corta o acesso: pede confirmação. Ativar não.
    if (user.active) {
      final confirmou = await _confirmar(
        titulo: 'Desativar usuário',
        mensagem:
            '${user.name} perderá o acesso ao sistema até ser ativado(a) '
            'novamente.',
        acao: 'Desativar',
      );
      if (!confirmou) return;
    }
    await _controller.alterarStatus(ativo: !user.active);
  }

  Future<void> _resetarSenha(UserModel user) async {
    final confirmou = await _confirmar(
      titulo: 'Resetar senha',
      mensagem:
          'Um link para criar uma nova senha será enviado para ${user.email}.',
      acao: 'Enviar',
    );
    if (confirmou) await _controller.resetarSenha();
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
    required String acao,
  }) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(acao),
          ),
        ],
      ),
    );
    return confirmou ?? false;
  }

  String _mensagemSucesso(UserEditSuccess sucesso) => switch (sucesso.acao) {
    UserEditAction.salvar => 'Cadastro de ${sucesso.user.name} atualizado',
    UserEditAction.alterarStatus =>
      sucesso.user.active
          ? '${sucesso.user.name} ativado(a)'
          : '${sucesso.user.name} desativado(a)',
    UserEditAction.resetarSenha =>
      'Link de nova senha enviado para ${sucesso.user.email}',
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<UserEditState>(userEditControllerProvider(widget.userId), (
      previous,
      next,
    ) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior.
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (next is UserEditSuccess) {
        messenger.showSnackBar(SnackBar(content: Text(_mensagemSucesso(next))));
        if (next.acao == UserEditAction.salvar) _voltar();
      }
      if (next is UserEditError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final dataState = ref.watch(userEditDataControllerProvider(widget.userId));
    final dados = dataState.dados;

    return AppScaffold(
      titulo: 'Editar Usuário',
      rotaAtual: '/usuario/editar',
      actions: const [AppBackButton(rotaAnterior: 'usuario')],
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: dataState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : dataState.errorMessage != null || dados == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      dataState.errorMessage ?? 'Usuário não encontrado',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _buildFormulario(dados),
        ),
      ),
    );
  }

  Widget _buildFormulario(UserEditModel dados) {
    final user = dados.user;
    final acaoState = ref.watch(userEditControllerProvider(widget.userId));
    final emAndamento = acaoState is UserEditInProgress ? acaoState.acao : null;
    final salvando = emAndamento == UserEditAction.salvar;

    return SingleChildScrollView(
      physics: _usandoMapa ? const NeverScrollableScrollPhysics() : null,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecalho(user: user),
          const SizedBox(height: 16),
          UserAdminActions(
            ativo: user.active,
            emAndamento: emAndamento,
            aoAlternarStatus: () => _alternarStatus(user),
            aoResetarSenha: () => _resetarSenha(user),
          ),

          // Mesmo formulário do cadastro, já preenchido. Durante as ações
          // de status/senha o formulário continua editável.
          if (user.role == UserRole.patient)
            PatientRegistrationForm(
              inicial: dados.cadastro,
              salvando: salvando,
              aoSalvar: _controller.salvar,
              labelSalvar: 'Editar cadastro',
              aoUsarMapa: _aoUsarMapa,
            )
          else
            ProfessionalRegistrationForm(
              inicial: dados.cadastro,
              salvando: salvando,
              aoSalvar: _controller.salvar,
              labelSalvar: 'Editar cadastro',
            ),
          // Espaço para o menu inferior flutuante
          const AppBottomSpacer(),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Foto do usuário com o perfil de acesso abaixo.
class _Cabecalho extends StatelessWidget {
  final UserModel user;

  const _Cabecalho({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.borderAccent,
          ),
          child: AppAvatar(fotoUrl: user.photoUrl, nome: user.name, raio: 50),
        ),
        const SizedBox(height: 8),
        Text(
          user.role.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
