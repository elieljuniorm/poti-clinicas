import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/app_primary_button.dart';
import '../../application/profile_edit_controller.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/profile_model.dart';
import '../states/profile_edit_state.dart';
import 'profile_field.dart';
import 'profile_header.dart';
import 'profile_section_card.dart';

/// Variação de edição: mesmos campos da visualização, agora liberados,
/// mais as seções de endereço e troca de senha.
class ProfileEditForm extends ConsumerStatefulWidget {
  final ProfileModel perfil;
  final VoidCallback aoCancelar;

  const ProfileEditForm({
    super.key,
    required this.perfil,
    required this.aoCancelar,
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

  // Endereço
  late final _cepController = TextEditingController(
    text: widget.perfil.address.zipCode,
  );
  late final _ruaController = TextEditingController(
    text: widget.perfil.address.street,
  );
  late final _numeroController = TextEditingController(
    text: widget.perfil.address.number,
  );
  late final _complementoController = TextEditingController(
    text: widget.perfil.address.complement,
  );
  late final _bairroController = TextEditingController(
    text: widget.perfil.address.neighborhood,
  );
  late final _cidadeController = TextEditingController(
    text: widget.perfil.address.city,
  );
  late final _ufController = TextEditingController(
    text: widget.perfil.address.state,
  );

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
      _cepController,
      _ruaController,
      _numeroController,
      _complementoController,
      _bairroController,
      _cidadeController,
      _ufController,
      _senhaAtualController,
      _novaSenhaController,
      _confirmarSenhaController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // ---------- Validações ----------

  String? _obrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  String? _validarEmail(String? valor) {
    final erro = _obrigatorio(valor);
    if (erro != null) return erro;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor!.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarData(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(valor.trim())) {
      return 'Use o formato DD/MM/AAAA';
    }
    return null;
  }

  String? _validarUf(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    if (valor.trim().length != 2) return 'Use a sigla (ex.: PI)';
    return null;
  }

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
      address: AddressModel(
        zipCode: _cepController.text.trim(),
        street: _ruaController.text.trim(),
        number: _numeroController.text.trim(),
        complement: _complementoController.text.trim(),
        neighborhood: _bairroController.text.trim(),
        city: _cidadeController.text.trim(),
        state: _ufController.text.trim().toUpperCase(),
      ),
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
                icon: Icons.person_outline,
                controller: _nomeController,
                habilitado: !salvando,
                validator: _obrigatorio,
              ),
              ProfileField(
                rotulo: 'E-MAIL',
                icon: Icons.email_outlined,
                controller: _emailController,
                habilitado: !salvando,
                teclado: TextInputType.emailAddress,
                validator: _validarEmail,
              ),
              ProfileField(
                rotulo: 'TELEFONE',
                icon: Icons.phone_outlined,
                controller: _telefoneController,
                habilitado: !salvando,
                teclado: TextInputType.phone,
              ),
              ProfileField(
                rotulo: 'DATA DE NASCIMENTO',
                icon: Icons.cake_outlined,
                controller: _nascimentoController,
                habilitado: !salvando,
                teclado: TextInputType.datetime,
                validator: _validarData,
              ),
              ProfileField(
                rotulo: 'CPF',
                icon: Icons.badge_outlined,
                valorInicial: widget.perfil.cpf,
                habilitado: false,
                textoAjuda: 'O CPF não pode ser alterado',
              ),
            ],
          ),

          // ---------- Endereço ----------
          ProfileSectionCard(
            titulo: 'ENDEREÇO',
            children: [
              ProfileField(
                rotulo: 'CEP',
                icon: Icons.local_post_office_outlined,
                controller: _cepController,
                habilitado: !salvando,
                teclado: TextInputType.number,
              ),
              ProfileField(
                rotulo: 'RUA',
                icon: Icons.signpost_outlined,
                controller: _ruaController,
                habilitado: !salvando,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ProfileField(
                      rotulo: 'NÚMERO',
                      icon: Icons.tag,
                      controller: _numeroController,
                      habilitado: !salvando,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ProfileField(
                      rotulo: 'COMPLEMENTO',
                      icon: Icons.apartment_outlined,
                      controller: _complementoController,
                      habilitado: !salvando,
                    ),
                  ),
                ],
              ),
              ProfileField(
                rotulo: 'BAIRRO',
                icon: Icons.map_outlined,
                controller: _bairroController,
                habilitado: !salvando,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ProfileField(
                      rotulo: 'CIDADE',
                      icon: Icons.location_city_outlined,
                      controller: _cidadeController,
                      habilitado: !salvando,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ProfileField(
                      rotulo: 'UF',
                      icon: Icons.flag_outlined,
                      controller: _ufController,
                      habilitado: !salvando,
                      validator: _validarUf,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ---------- Senha ----------
          ProfileSectionCard(
            titulo: 'ALTERAR SENHA',
            subtitulo: 'PREENCHA APENAS SE QUISER TROCAR A SENHA',
            children: [
              ProfileField(
                rotulo: 'SENHA ATUAL',
                icon: Icons.lock_outline,
                controller: _senhaAtualController,
                habilitado: !salvando,
                senha: true,
                validator: _validarSenhaAtual,
              ),
              ProfileField(
                rotulo: 'NOVA SENHA',
                icon: Icons.key,
                controller: _novaSenhaController,
                habilitado: !salvando,
                senha: true,
                validator: _validarNovaSenha,
              ),
              ProfileField(
                rotulo: 'CONFIRMAR NOVA SENHA',
                icon: Icons.key,
                controller: _confirmarSenhaController,
                habilitado: !salvando,
                senha: true,
                validator: _validarConfirmacao,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  label: 'SALVAR',
                  carregando: salvando,
                  onPressed: _salvar,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppPrimaryButton(
                  label: 'CANCELAR',
                  contornado: true,
                  onPressed: salvando ? null : widget.aoCancelar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
