import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/formatters/cep_input_formatter.dart';
import '../../../../core/ui/widgets/app_primary_button.dart';
import '../../../../core/utils/cep.dart';
import '../../application/address_map_controller.dart';
import '../../application/profile_edit_controller.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/profile_model.dart';
import '../states/profile_edit_state.dart';
import 'address_map.dart';
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

  // Endereço
  late final _cepController = TextEditingController(
    text: Cep.mascarar(widget.perfil.address.zipCode),
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

  // Campos que mudam o local no mapa. Número e complemento ficam de fora.
  late final _camposDoMapa = [
    _cepController,
    _ruaController,
    _bairroController,
    _cidadeController,
    _ufController,
  ];

  // Evita buscar de novo quando nada mudou (o listener também dispara
  // ao mover o cursor) ou quando quem mudou os campos foi o próprio mapa.
  late AddressModel _ultimoEnderecoBuscado = _enderecoDoMapa;
  bool _preenchendoPeloMapa = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _camposDoMapa) {
      controller.addListener(_aoMudarEndereco);
    }
    // Primeira busca com o endereço já salvo. Microtask: o provider
    // não pode ser alterado durante o build.
    Future.microtask(
      () => ref
          .read(addressMapControllerProvider.notifier)
          .buscarEndereco(_ultimoEnderecoBuscado),
    );
  }

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

  String? _validarCep(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    if (!Cep.valido(valor.trim())) return 'Use o formato 00000-000';
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

  // ---------- Mapa ----------

  AddressModel get _enderecoDigitado => AddressModel(
    zipCode: _cepController.text.trim(),
    street: _ruaController.text.trim(),
    number: _numeroController.text.trim(),
    complement: _complementoController.text.trim(),
    neighborhood: _bairroController.text.trim(),
    city: _cidadeController.text.trim(),
    state: _ufController.text.trim().toUpperCase(),
  );

  /// Só o que localiza o endereço: sem número e complemento.
  AddressModel get _enderecoDoMapa => AddressModel(
    zipCode: _cepController.text.trim(),
    street: _ruaController.text.trim(),
    neighborhood: _bairroController.text.trim(),
    city: _cidadeController.text.trim(),
    state: _ufController.text.trim().toUpperCase(),
  );

  void _aoMudarEndereco() {
    if (_preenchendoPeloMapa) return;

    final endereco = _enderecoDoMapa;
    if (endereco == _ultimoEnderecoBuscado) return;
    _ultimoEnderecoBuscado = endereco;

    ref.read(addressMapControllerProvider.notifier).agendarBusca(endereco);
  }

  /// Toque no mapa: preenche rua, CEP, bairro, cidade e UF com o endereço
  /// do ponto escolhido. Número e complemento são do usuário e não mudam.
  void _aoSelecionarNoMapa(AddressModel endereco) {
    _preenchendoPeloMapa = true;
    _cepController.text = Cep.mascarar(endereco.zipCode);
    _ruaController.text = endereco.street;
    _bairroController.text = endereco.neighborhood;
    _cidadeController.text = endereco.city;
    _ufController.text = endereco.state;
    _preenchendoPeloMapa = false;

    _ultimoEnderecoBuscado = _enderecoDoMapa;
  }

  // ---------- Ações ----------

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final perfil = widget.perfil.copyWith(
      name: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      phone: _telefoneController.text.trim(),
      birthDate: _nascimentoController.text.trim(),
      address: _enderecoDigitado,
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
                formatadores: [CepInputFormatter()],
                validator: _validarCep,
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
              AddressMap(
                habilitado: !salvando,
                aoSelecionarEndereco: _aoSelecionarNoMapa,
                aoUsarMapa: widget.aoUsarMapa,
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
