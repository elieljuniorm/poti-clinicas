import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/formatters/mask_input_formatter.dart';
import '../../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/address_form_section.dart';
import '../../../../profile/ui/widgets/profile_dropdown_field.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../application/user_registration_controller.dart';
import '../../../application/users_controller.dart';
import '../../../domain/models/patient_category.dart';
import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/user_role.dart';
import '../../states/user_registration_state.dart';
import 'registration_contact_fields.dart';

/// Cadastro de paciente: vínculo com um profissional, perfil fixo
/// "Paciente", categoria e endereço com mapa (mesma lógica da edição
/// do perfil, aqui preenchida pela clínica).
class PatientRegistrationForm extends ConsumerStatefulWidget {
  final VoidCallback aoCancelar;

  /// Repassado ao mapa para a tela travar a rolagem.
  final ValueChanged<bool>? aoUsarMapa;

  const PatientRegistrationForm({
    super.key,
    required this.aoCancelar,
    this.aoUsarMapa,
  });

  @override
  ConsumerState<PatientRegistrationForm> createState() =>
      _PatientRegistrationFormState();
}

class _PatientRegistrationFormState
    extends ConsumerState<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _endereco = AddressFormControllers();

  String? _profissionalId;
  PatientCategory? _categoria;

  @override
  void dispose() {
    for (final controller in [
      _nomeController,
      _emailController,
      _telefoneController,
      _nascimentoController,
      _cpfController,
    ]) {
      controller.dispose();
    }
    _endereco.dispose();
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
            role: UserRole.patient,
            document: _cpfController.text,
            patientCategory: _categoria,
            professionalId: _profissionalId,
            address: _endereco.endereco,
          ),
        );
  }

  /// Select de profissionais ativos, vindos da lista de usuários.
  Widget _buildProfissional(bool salvando) {
    final usersState = ref.watch(usersControllerProvider);
    final profissionais = {
      for (final user in usersState.users)
        if (user.role == UserRole.professional && user.active)
          user.id: user.name,
    };

    final carregando = usersState.isLoading && profissionais.isEmpty;
    final dica = carregando
        ? 'Carregando profissionais...'
        : usersState.errorMessage != null && profissionais.isEmpty
        ? 'Não foi possível carregar os profissionais'
        : 'Selecione';

    return ProfileDropdownField<String>(
      rotulo: 'PROFISSIONAL',
      opcoes: profissionais.keys.toList(),
      rotuloOpcao: (id) => profissionais[id] ?? '',
      valor: _profissionalId,
      habilitado: !salvando && profissionais.isNotEmpty,
      dica: dica,
      aoMudar: (id) => setState(() => _profissionalId = id),
      validator: FormValidators.selecao,
    );
  }

  @override
  Widget build(BuildContext context) {
    final salvando =
        ref.watch(userRegistrationControllerProvider) is UserRegistrationSaving;

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
            nascimentoObrigatorio: true,
          ),
          _buildProfissional(salvando),
          // Mesmo select do cadastro de profissional, fixo em "Paciente".
          const ProfileDropdownField<UserRole>(
            rotulo: 'PERFIL DE ACESSO',
            opcoes: [UserRole.patient],
            rotuloOpcao: _rotuloPerfil,
            valor: UserRole.patient,
            habilitado: false,
            textoAjuda: 'Fixo no cadastro de paciente',
          ),
          ProfileField(
            rotulo: 'CPF',
            icon: Symbols.id_card,
            controller: _cpfController,
            habilitado: !salvando,
            teclado: TextInputType.number,
            formatadores: [MaskInputFormatter.cpf()],
            dica: '000.000.000-00',
            validator: FormValidators.cpf,
          ),
          ProfileDropdownField<PatientCategory>(
            rotulo: 'CATEGORIA',
            opcoes: PatientCategory.values,
            rotuloOpcao: _rotuloCategoria,
            valor: _categoria,
            habilitado: !salvando,
            aoMudar: (valor) => setState(() => _categoria = valor),
            validator: FormValidators.selecao,
          ),

          // ---------- Endereço (com mapa) ----------
          AddressFormSection(
            controllers: _endereco,
            habilitado: !salvando,
            aoUsarMapa: widget.aoUsarMapa,
            buscarAoAbrir: false,
            obrigatorio: true,
            comDivisor: true,
          ),

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

String _rotuloPerfil(UserRole perfil) => perfil.label;

String _rotuloCategoria(PatientCategory categoria) => categoria.label;
