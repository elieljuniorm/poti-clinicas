import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/widgets/app_section_divider.dart';
import '../../../../../core/ui/widgets/app_select_field.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../domain/models/bank_info_model.dart';

/// Campos dos dados financeiros. Ficam com o formulário (que lê os valores
/// ao salvar); a [BankInfoSection] só os exibe e valida.
class BankInfoFormControllers {
  final banco = TextEditingController();
  final agencia = TextEditingController();
  final conta = TextEditingController();
  final chavePix = TextEditingController();
  AccountType? tipoConta;
  PixKeyType? tipoChavePix;

  /// Algum dado da conta bancária foi informado: aí a conta fica completa.
  bool get informouConta =>
      banco.text.trim().isNotEmpty ||
      agencia.text.trim().isNotEmpty ||
      conta.text.trim().isNotEmpty ||
      tipoConta != null;

  bool get informouPix =>
      chavePix.text.trim().isNotEmpty || tipoChavePix != null;

  /// `null` quando a seção ficou em branco.
  BankInfoModel? get dados {
    if (!informouConta && !informouPix) return null;
    return BankInfoModel(
      bank: banco.text.trim(),
      agency: agencia.text.trim(),
      account: conta.text.trim(),
      accountType: tipoConta,
      pixKeyType: tipoChavePix,
      pixKey: chavePix.text.trim(),
    );
  }

  void dispose() {
    for (final controller in [banco, agencia, conta, chavePix]) {
      controller.dispose();
    }
  }
}

/// Área "DADOS FINANCEIROS" do cadastro de profissional.
///
/// Opcional: pode ficar em branco. Se algo da conta for preenchido,
/// banco, agência, conta e tipo passam a ser obrigatórios; o mesmo vale
/// para tipo e chave PIX.
class BankInfoSection extends StatefulWidget {
  final BankInfoFormControllers controllers;
  final bool habilitado;

  const BankInfoSection({
    super.key,
    required this.controllers,
    this.habilitado = true,
  });

  @override
  State<BankInfoSection> createState() => _BankInfoSectionState();
}

class _BankInfoSectionState extends State<BankInfoSection> {
  BankInfoFormControllers get _campos => widget.controllers;

  // Agência e conta: números com dígito opcional (ex.: 1234-5).
  static final _formatoConta = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
    LengthLimitingTextInputFormatter(15),
  ];

  String? _seConta(String? valor) =>
      _campos.informouConta ? FormValidators.obrigatorio(valor) : null;

  String? _seContaSelecao<T>(T? valor) =>
      _campos.informouConta ? FormValidators.selecao(valor) : null;

  String? _sePix(String? valor) =>
      _campos.informouPix ? FormValidators.obrigatorio(valor) : null;

  String? _sePixSelecao<T>(T? valor) =>
      _campos.informouPix ? FormValidators.selecao(valor) : null;

  String get _dicaChavePix => switch (_campos.tipoChavePix) {
    PixKeyType.document => '000.000.000-00',
    PixKeyType.email => 'email@.com',
    PixKeyType.phone => '(91) 9 9999-9999',
    PixKeyType.random => 'Chave aleatória',
    null => 'Selecione o tipo da chave',
  };

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.habilitado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionDivider(titulo: 'DADOS FINANCEIROS'),
        ProfileField(
          rotulo: 'BANCO',
          icon: Symbols.account_balance,
          controller: _campos.banco,
          habilitado: habilitado,
          dica: 'Ex.: 001 - Banco do Brasil',
          validator: _seConta,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ProfileField(
                rotulo: 'AGÊNCIA',
                icon: Symbols.tag,
                controller: _campos.agencia,
                habilitado: habilitado,
                teclado: TextInputType.number,
                formatadores: _formatoConta,
                dica: '0000',
                validator: _seConta,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ProfileField(
                rotulo: 'CONTA',
                icon: Symbols.credit_card,
                controller: _campos.conta,
                habilitado: habilitado,
                teclado: TextInputType.number,
                formatadores: _formatoConta,
                dica: '00000-0',
                validator: _seConta,
              ),
            ),
          ],
        ),
        AppSelectField<AccountType>(
          rotulo: 'TIPO DE CONTA',
          opcoes: AccountType.values,
          rotuloOpcao: (tipo) => tipo.label,
          valor: _campos.tipoConta,
          habilitado: habilitado,
          aoMudar: (tipo) => setState(() => _campos.tipoConta = tipo),
          validator: _seContaSelecao,
        ),
        AppSelectField<PixKeyType>(
          rotulo: 'TIPO DE CHAVE PIX',
          opcoes: PixKeyType.values,
          rotuloOpcao: (tipo) => tipo.label,
          valor: _campos.tipoChavePix,
          habilitado: habilitado,
          aoMudar: (tipo) => setState(() => _campos.tipoChavePix = tipo),
          validator: _sePixSelecao,
        ),
        ProfileField(
          rotulo: 'CHAVE PIX',
          icon: Icons.pix_sharp,
          controller: _campos.chavePix,
          habilitado: habilitado,
          dica: _dicaChavePix,
          validator: _sePix,
        ),
      ],
    );
  }
}
