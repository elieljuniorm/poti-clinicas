import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../core/utils/form_validators.dart';
import '../../application/profile_edit_controller.dart';
import '../../domain/models/profile_model.dart';
import '../states/profile_edit_state.dart';
import 'address_form_section.dart';
import 'profile_field.dart';
import 'profile_header.dart';
import 'profile_section_card.dart';

/// Variação de edição: mesmos campos da visualização, agora liberados,
/// mais as seções de endereço (com mapa) e troca de senha.
class ProfileEditForm extends ConsumerStatefulWidget {
  final ProfileModel perfil;
  final VoidCallback aoCancelar;

  /// Repassado ao [AddressMap] para a tela travar a rolagem.
  final ValueChanged<bool>? aoUsarMapa;

  const ProfileEditForm({
    super.key,
    required this.perfil,
    required this.aoCancelar,
    this.aoUsarMapa,
  });

  @override
  ConsumerState<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();

  // Dados pessoais
  late final _nomeController = TextEditingController(text: widget.perfil.name);
  late final _emailController = TextEditingController(
    text: widget.perfil.email,
  );
  late final _telefoneController = TextEditingController(
    text: widget.perfil.phone,
  );
  late final _nascimentoController = TextEditingController(
    text: widget.perfil.birthDate,
  );

  // Endereço (exibido e ligado ao mapa pela [AddressFormSection])
  late final _endereco = AddressFormControllers(widget.perfil.address);

  // Senha (vazia = não trocar)
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _nomeController,
      _emailController,
      _telefoneController,
      _nascimentoController,
      _senhaAtualController,
      _novaSenhaController,
      _confirmarSenhaController,
    ]) {
      controller.dispose();
    }
    _endereco.dispose();
    super.dispose();
  }

  // ---------- Validações ----------

  bool get _querTrocarSenha =>
      _novaSenhaController.text.isNotEmpty ||
      _confirmarSenhaController.text.isNotEmpty;

  String? _validarSenhaAtual(String? valor) {
    if (_querTrocarSenha && (valor == null || valor.isEmpty)) {
      return 'Informe a senha atual';
    }
    return null;
  }

  String? _validarNovaSenha(String? valor) {
    if (!_querTrocarSenha) return null;
    if (valor == null || valor.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validarConfirmacao(String? valor) {
    if (!_querTrocarSenha) return null;
    if (valor != _novaSenhaController.text) return 'As senhas não conferem';
    return null;
  }

  // ---------- Ações ----------

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final perfil = widget.perfil.copyWith(
      name: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      phone: _telefoneController.text.trim(),
      birthDate: _nascimentoController.text.trim(),
      address: _endereco.endereco,
    );

    ref
        .read(profileEditControllerProvider.notifier)
        .salvar(
          perfil: perfil,
          senhaAtual: _senhaAtualController.text,
          novaSenha: _novaSenhaController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final salvando =
        ref.watch(profileEditControllerProvider) is ProfileEditSaving;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ProfileHeader(
            nome: widget.perfil.name,
            fotoUrl: widget.perfil.photoUrl,
          ),
          const SizedBox(height: 18),

          // ---------- Dados pessoais ----------
          ProfileSectionCard(
            titulo: 'DADOS PESSOAIS',
            children: [
              ProfileField(
                rotulo: 'NOME',
                icon: Symbols.person,
                controller: _nomeController,
                habilitado: !salvando,
                validator: FormValidators.obrigatorio,
              ),
              ProfileField(
                rotulo: 'E-MAIL',
                icon: Symbols.mail,
                controller: _emailController,
                habilitado: !salvando,
                teclado: TextInputType.emailAddress,
                validator: FormValidators.email,
              ),
              ProfileField(
                rotulo: 'TELEFONE',
                icon: Symbols.call,
                controller: _telefoneController,
                habilitado: !salvando,
                teclado: TextInputType.phone,
              ),
              ProfileField(
                rotulo: 'DATA DE NASCIMENTO',
                icon: Symbols.cake,
                controller: _nascimentoController,
                habilitado: !salvando,
                teclado: TextInputType.datetime,
                validator: FormValidators.data,
              ),
              ProfileField(
                rotulo: 'CPF',
                icon: Symbols.badge,
                valorInicial: widget.perfil.cpf,
                habilitado: false,
                textoAjuda: 'O CPF não pode ser alterado',
              ),
            ],
          ),

          // ---------- Endereço (com mapa) ----------
          AddressFormSection(
            controllers: _endereco,
            habilitado: !salvando,
            aoUsarMapa: widget.aoUsarMapa,
          ),

          // ---------- Senha ----------
          ProfileSectionCard(
            titulo: 'ALTERAR SENHA',
            subtitulo: 'PREENCHA APENAS SE QUISER TROCAR A SENHA',
            children: [
              ProfileField(
                rotulo: 'SENHA ATUAL',
                icon: Symbols.lock,
                controller: _senhaAtualController,
                habilitado: !salvando,
                senha: true,
                validator: _validarSenhaAtual,
              ),
              ProfileField(
                rotulo: 'NOVA SENHA',
                icon: Symbols.key,
                controller: _novaSenhaController,
                habilitado: !salvando,
                senha: true,
                validator: _validarNovaSenha,
              ),
              ProfileField(
                rotulo: 'CONFIRMAR NOVA SENHA',
                icon: Symbols.key,
                controller: _confirmarSenhaController,
                habilitado: !salvando,
                senha: true,
                validator: _validarConfirmacao,
              ),
            ],
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
