import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/formatters/cep_input_formatter.dart';
import '../../../../core/ui/widgets/app_section_divider.dart';
import '../../../../core/utils/cep.dart';
import '../../../../core/utils/form_validators.dart';
import '../../application/address_map_controller.dart';
import '../../domain/models/address_model.dart';
import 'address_map.dart';
import 'profile_field.dart';
import 'profile_section_card.dart';

/// Campos de texto do endereço. Ficam com o formulário (que lê os valores
/// ao salvar); a [AddressFormSection] só os exibe e liga ao mapa.
class AddressFormControllers {
  final TextEditingController cep;
  final TextEditingController rua;
  final TextEditingController numero;
  final TextEditingController complemento;
  final TextEditingController bairro;
  final TextEditingController cidade;
  final TextEditingController uf;

  AddressFormControllers([AddressModel endereco = const AddressModel()])
    : cep = TextEditingController(text: Cep.mascarar(endereco.zipCode)),
      rua = TextEditingController(text: endereco.street),
      numero = TextEditingController(text: endereco.number),
      complemento = TextEditingController(text: endereco.complement),
      bairro = TextEditingController(text: endereco.neighborhood),
      cidade = TextEditingController(text: endereco.city),
      uf = TextEditingController(text: endereco.state);

  /// Endereço completo, como foi digitado.
  AddressModel get endereco => AddressModel(
    zipCode: cep.text.trim(),
    street: rua.text.trim(),
    number: numero.text.trim(),
    complement: complemento.text.trim(),
    neighborhood: bairro.text.trim(),
    city: cidade.text.trim(),
    state: uf.text.trim().toUpperCase(),
  );

  /// Só o que localiza o endereço: sem número e complemento.
  AddressModel get enderecoDoMapa => AddressModel(
    zipCode: cep.text.trim(),
    street: rua.text.trim(),
    neighborhood: bairro.text.trim(),
    city: cidade.text.trim(),
    state: uf.text.trim().toUpperCase(),
  );

  /// Campos que mudam o local no mapa. Número e complemento ficam de fora.
  List<TextEditingController> get camposDoMapa => [
    cep,
    rua,
    bairro,
    cidade,
    uf,
  ];

  void dispose() {
    for (final controller in [
      cep,
      rua,
      numero,
      complemento,
      bairro,
      cidade,
      uf,
    ]) {
      controller.dispose();
    }
  }
}

/// Seção "ENDEREÇO" com os campos e o mapa ligados nos dois sentidos:
/// digitar move o pino; tocar no mapa preenche os campos.
///
/// Usada na edição do perfil (o próprio usuário) e nos cadastros feitos
/// pela clínica: paciente (com mapa) e profissional ([mostrarMapa] = `false`).
class AddressFormSection extends ConsumerStatefulWidget {
  final AddressFormControllers controllers;
  final bool habilitado;

  /// Repassado ao [AddressMap] para a tela travar a rolagem.
  final ValueChanged<bool>? aoUsarMapa;

  /// Busca o endereço já preenchido ao abrir (edição). No cadastro, com os
  /// campos vazios, o mapa começa em Belém sem buscar nada.
  final bool buscarAoAbrir;

  /// Exige CEP, rua, número, bairro, cidade e UF (complemento é opcional).
  final bool obrigatorio;

  /// Sem o mapa, ficam só os campos e nada é buscado (endereço básico).
  final bool mostrarMapa;

  /// Título como [AppSectionDivider] (linha com texto no centro), usado nos
  /// cadastros. Sem ele, título de seção à esquerda, como no perfil.
  final bool comDivisor;

  const AddressFormSection({
    super.key,
    required this.controllers,
    this.habilitado = true,
    this.aoUsarMapa,
    this.buscarAoAbrir = true,
    this.obrigatorio = false,
    this.mostrarMapa = true,
    this.comDivisor = false,
  });

  @override
  ConsumerState<AddressFormSection> createState() => _AddressFormSectionState();
}

class _AddressFormSectionState extends ConsumerState<AddressFormSection> {
  AddressFormControllers get _campos => widget.controllers;

  // Evita buscar de novo quando nada mudou (o listener também dispara
  // ao mover o cursor) ou quando quem mudou os campos foi o próprio mapa.
  late AddressModel _ultimoEnderecoBuscado = _campos.enderecoDoMapa;
  bool _preenchendoPeloMapa = false;

  @override
  void initState() {
    super.initState();
    if (!widget.mostrarMapa) return;

    for (final controller in _campos.camposDoMapa) {
      controller.addListener(_aoMudarEndereco);
    }
    if (widget.buscarAoAbrir) {
      // Primeira busca com o endereço já salvo. Microtask: o provider
      // não pode ser alterado durante o build.
      Future.microtask(
        () => ref
            .read(addressMapControllerProvider.notifier)
            .buscarEndereco(_ultimoEnderecoBuscado),
      );
    }
  }

  @override
  void dispose() {
    // Os controllers são do formulário; aqui só saem os listeners.
    for (final controller in _campos.camposDoMapa) {
      controller.removeListener(_aoMudarEndereco);
    }
    super.dispose();
  }

  // ---------- Validações ----------

  String? _talvezObrigatorio(String? valor) =>
      widget.obrigatorio ? FormValidators.obrigatorio(valor) : null;

  String? _validarCep(String? valor) {
    if (valor == null || valor.isEmpty) return _talvezObrigatorio(valor);
    if (!Cep.valido(valor.trim())) return 'Use o formato 00000-000';
    return null;
  }

  String? _validarUf(String? valor) {
    if (valor == null || valor.isEmpty) return _talvezObrigatorio(valor);
    if (valor.trim().length != 2) return 'Use a sigla (ex.: PI)';
    return null;
  }

  // ---------- Mapa ----------

  void _aoMudarEndereco() {
    if (_preenchendoPeloMapa) return;

    final endereco = _campos.enderecoDoMapa;
    if (endereco == _ultimoEnderecoBuscado) return;
    _ultimoEnderecoBuscado = endereco;

    ref.read(addressMapControllerProvider.notifier).agendarBusca(endereco);
  }

  /// Toque no mapa: preenche rua, CEP, bairro, cidade e UF com o endereço
  /// do ponto escolhido. Número e complemento são do usuário e não mudam.
  void _aoSelecionarNoMapa(AddressModel endereco) {
    _preenchendoPeloMapa = true;
    _campos.cep.text = Cep.mascarar(endereco.zipCode);
    _campos.rua.text = endereco.street;
    _campos.bairro.text = endereco.neighborhood;
    _campos.cidade.text = endereco.city;
    _campos.uf.text = endereco.state;
    _preenchendoPeloMapa = false;

    _ultimoEnderecoBuscado = _campos.enderecoDoMapa;
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.habilitado;
    final campos = [
      ProfileField(
        rotulo: 'CEP',
        icon: Symbols.local_post_office,
        controller: _campos.cep,
        habilitado: habilitado,
        teclado: TextInputType.number,
        formatadores: [CepInputFormatter()],
        dica: '00000-000',
        validator: _validarCep,
      ),
      ProfileField(
        rotulo: 'RUA',
        icon: Symbols.signpost,
        controller: _campos.rua,
        habilitado: habilitado,
        validator: _talvezObrigatorio,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ProfileField(
              rotulo: 'NÚMERO',
              icon: Symbols.tag,
              controller: _campos.numero,
              habilitado: habilitado,
              validator: _talvezObrigatorio,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ProfileField(
              rotulo: 'COMPLEMENTO',
              icon: Symbols.apartment,
              controller: _campos.complemento,
              habilitado: habilitado,
            ),
          ),
        ],
      ),
      ProfileField(
        rotulo: 'BAIRRO',
        icon: Symbols.map,
        controller: _campos.bairro,
        habilitado: habilitado,
        validator: _talvezObrigatorio,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ProfileField(
              rotulo: 'CIDADE',
              icon: Symbols.location_city,
              controller: _campos.cidade,
              habilitado: habilitado,
              validator: _talvezObrigatorio,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ProfileField(
              rotulo: 'UF',
              icon: Symbols.flag,
              controller: _campos.uf,
              habilitado: habilitado,
              validator: _validarUf,
            ),
          ),
        ],
      ),
      if (widget.mostrarMapa)
        AddressMap(
          habilitado: habilitado,
          aoSelecionarEndereco: _aoSelecionarNoMapa,
          aoUsarMapa: widget.aoUsarMapa,
        ),
    ];

    if (!widget.comDivisor) {
      return ProfileSectionCard(titulo: 'ENDEREÇO', children: campos);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionDivider(titulo: 'ENDEREÇO'),
        ...campos,
      ],
    );
  }
}
