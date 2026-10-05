import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_segmented_control.dart';
import '../../application/user_registration_controller.dart';
import '../states/user_registration_state.dart';
import '../widgets/registration/patient_registration_form.dart';
import '../widgets/registration/professional_registration_form.dart';

/// Tipo de cadastro escolhido no seletor do topo.
enum _TipoCadastro {
  professional('Profissional', 'PROFISSIONAL'),
  patient('Paciente', 'PACIENTE');

  final String label;
  final String frase;

  const _TipoCadastro(this.label, this.frase);
}

/// Tela "Cadastrar Usuário", aberta pelo card da tela de Usuários.
///
/// Dois formulários no seletor do topo: profissional (equipe da clínica)
/// e paciente. Trocar de aba não perde o que já foi digitado.
class UserRegistrationScreen extends ConsumerStatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  ConsumerState<UserRegistrationScreen> createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState
    extends ConsumerState<UserRegistrationScreen> {
  _TipoCadastro _tipo = _TipoCadastro.professional;

  // Com o dedo no mapa, a página para de rolar e o arraste move o mapa.
  bool _usandoMapa = false;

  void _aoUsarMapa(bool usando) {
    if (usando != _usandoMapa) setState(() => _usandoMapa = usando);
  }

  void _voltar() => context.goNamed('usuario');

  @override
  Widget build(BuildContext context) {
    ref.listen<UserRegistrationState>(userRegistrationControllerProvider, (
      previous,
      next,
    ) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior.
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (next is UserRegistrationSuccess) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${next.user.name} cadastrado(a) com sucesso'),
          ),
        );
        _voltar();
      }
      if (next is UserRegistrationError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final salvando =
        ref.watch(userRegistrationControllerProvider) is UserRegistrationSaving;

    return AppScaffold(
      titulo: 'Cadastrar Usuário',
      rotaAtual: '/usuario/novo',
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
          child: SingleChildScrollView(
            physics: _usandoMapa ? const NeverScrollableScrollPhysics() : null,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'PREENCHA AS INFORMAÇÕES ABAIXO PARA CONCLUIR O '
                  'CADASTRO DO ${_tipo.frase}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pageDescription,
                ),
                const SizedBox(height: 16),

                // Durante o salvamento não dá para trocar de formulário.
                IgnorePointer(
                  ignoring: salvando,
                  child: AppSegmentedControl<_TipoCadastro>(
                    opcoes: _TipoCadastro.values,
                    rotulo: (tipo) => tipo.label,
                    selecionado: _tipo,
                    aoSelecionar: (tipo) => setState(() => _tipo = tipo),
                  ),
                ),
                const SizedBox(height: 16),

                // maintainState: o formulário escondido guarda o que foi
                // digitado, mas não ocupa espaço na página.
                Visibility(
                  visible: _tipo == _TipoCadastro.professional,
                  maintainState: true,
                  child: ProfessionalRegistrationForm(aoCancelar: _voltar),
                ),
                Visibility(
                  visible: _tipo == _TipoCadastro.patient,
                  maintainState: true,
                  child: PatientRegistrationForm(
                    aoCancelar: _voltar,
                    aoUsarMapa: _aoUsarMapa,
                  ),
                ),
                // Espaço para o menu inferior flutuante
                const AppBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
