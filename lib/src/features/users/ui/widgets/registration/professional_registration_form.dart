import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/formatters/mask_input_formatter.dart';
import '../../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../../core/ui/widgets/app_select_field.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/address_form_section.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../application/user_registration_controller.dart';
import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/user_role.dart';
import '../../states/user_registration_state.dart';
import 'bank_info_section.dart';
import 'registration_contact_fields.dart';

/// Cadastro da equipe: profissional de saúde, administrador, recepção
/// e colaborador, escolhidos no select "PERFIL DE ACESSO".
/// Inclui endereço básico (sem mapa) e dados financeiros.
class ProfessionalRegistrationForm extends ConsumerStatefulWidget {
  final VoidCallback aoCancelar;

  const ProfessionalRegistrationForm({super.key, required this.aoCancelar});

  /// Perfis disponíveis neste formulário (paciente tem formulário próprio).
  static const perfis = [
    UserRole.professional,
    UserRole.admin,
    UserRole.reception,
    UserRole.collaborator,
  ];

  /// No select, "Profissional" fica explícito como profissional de saúde.
  static String rotuloPerfil(UserRole perfil) =>
      perfil == UserRole.professional ? 'Profissional de saúde' : perfil.label;

  @override
  ConsumerState<ProfessionalRegistrationForm> createState() =>
      _ProfessionalRegistrationFormState();
}

class _ProfessionalRegistrationFormState
    extends ConsumerState<ProfessionalRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _conselhoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _endereco = AddressFormControllers();
  final _financeiro = BankInfoFormControllers();

  UserRole? _perfil;

  bool get _profissionalDeSaude => _perfil == UserRole.professional;

  @override
  void dispose() {
    for (final controller in [
      _nomeController,
      _emailController,
      _telefoneController,
      _nascimentoController,
      _documentoController,
      _conselhoController,
      _descricaoController,
    ]) {
      controller.dispose();
    }
    _endereco.dispose();
    _financeiro.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(userRegistrationControllerProvider.notifier)
        .cadastrar(
          UserRegistrationModel(
            name: _nomeController.text.trim(),
            email: _emailController.text.trim(),
            phone: _telefoneController.text,
            birthDate: _nascimentoController.text.trim(),
            role: _perfil!,
            document: _documentoController.text,
            // O conselho só vale para profissional de saúde.
            councilNumber: _profissionalDeSaude
                ? _conselhoController.text
                : null,
            description: _descricaoController.text,
            address: _endereco.endereco,
            bankInfo: _financeiro.dados,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final salvando =
        ref.watch(userRegistrationControllerProvider) is UserRegistrationSaving;
    final perfil = _perfil;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegistrationContactFields(
            nome: _nomeController,
            email: _emailController,
            telefone: _telefoneController,
            nascimento: _nascimentoController,
            habilitado: !salvando,
            dicaEmail: 'email@gmail.com',
          ),
          AppSelectField<UserRole>(
            rotulo: 'PERFIL DE ACESSO',
            opcoes: ProfessionalRegistrationForm.perfis,
            rotuloOpcao: ProfessionalRegistrationForm.rotuloPerfil,
            valor: _perfil,
            habilitado: !salvando,
            aoMudar: (valor) => setState(() => _perfil = valor),
            validator: FormValidators.selecao,
          ),
          ProfileField(
            rotulo: 'CPF / CNPJ',
            icon: Symbols.id_card,
            controller: _documentoController,
            habilitado: !salvando,
            teclado: TextInputType.number,
            formatadores: [CpfCnpjInputFormatter()],
            dica: '000.000.000-00',
            validator: FormValidators.cpfCnpj,
          ),

          // Campos que dependem do perfil escolhido.
          if (_profissionalDeSaude) ...[
            ProfileField(
              rotulo: 'NÚMERO DE INSCRIÇÃO NO CONSELHO',
              icon: Symbols.id_card,
              controller: _conselhoController,
              habilitado: !salvando,
              dica: '000000-F',
              validator: FormValidators.obrigatorio,
            ),
            ProfileField(
              rotulo: 'ESPECIALIDADE',
              icon: Symbols.stethoscope,
              controller: _descricaoController,
              habilitado: !salvando,
              dica: 'Ex.: Fisioterapeuta',
              validator: FormValidators.obrigatorio,
            ),
          ] else if (perfil != null)
            ProfileField(
              rotulo: 'SETOR',
              icon: Symbols.work,
              controller: _descricaoController,
              habilitado: !salvando,
              dica:
                  'Ex.: ${perfil == UserRole.collaborator ? 'Financeiro' : perfil.label}',
            ),

          // ---------- Endereço (básico, sem mapa) ----------
          AddressFormSection(
            controllers: _endereco,
            habilitado: !salvando,
            mostrarMapa: false,
            obrigatorio: true,
            comDivisor: true,
          ),

          // ---------- Dados financeiros ----------
          BankInfoSection(controllers: _financeiro, habilitado: !salvando),

          const SizedBox(height: 8),
          AppSaveCancelButtons(
            salvando: salvando,
            aoSalvar: _salvar,
            aoCancelar: widget.aoCancelar,
          ),
        ],
      ),
    );
  }
}
