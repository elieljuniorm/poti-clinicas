import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';

/// Campo de cadastro com rótulo acima.
///
/// Com [habilitado] = `false`, vira só leitura (fundo cinza, borda suave).
/// É assim que a tela de visualização reaproveita o mesmo layout da edição.
class ProfileField extends StatefulWidget {
  final String rotulo;

  /// Ícone à esquerda do texto. Opcional (ex.: data de nascimento sem ícone).
  final IconData? icon;
  final TextEditingController? controller;

  /// Usado quando não há [controller] (modo só leitura).
  final String? valorInicial;
  final bool habilitado;
  final bool senha;
  final TextInputType? teclado;
  final String? textoAjuda;

  /// Texto de exemplo exibido com o campo vazio (ex.: "Nome Completo").
  final String? dica;
  final String? Function(String?)? validator;

  /// Máscaras de digitação (ex.: [CepInputFormatter]).
  final List<TextInputFormatter>? formatadores;

  /// Altura fixa para textos longos (ex.: caso clínico): o campo aceita
  /// várias linhas e rola por dentro, sem crescer. Uma mensagem de erro
  /// ocupa parte dessa altura.
  final double? altura;

  /// Mostra o valor com o visual de campo editável, mas sem deixar
  /// digitar (ex.: total calculado a partir de outros campos).
  final bool somenteLeitura;

  /// Texto fixo depois do valor digitado (ex.: "%").
  final String? sufixo;

  const ProfileField({
    super.key,
    required this.rotulo,
    this.icon,
    this.controller,
    this.valorInicial,
    this.habilitado = true,
    this.senha = false,
    this.teclado,
    this.textoAjuda,
    this.dica,
    this.validator,
    this.formatadores,
    this.altura,
    this.somenteLeitura = false,
    this.sufixo,
  });

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  late bool _ocultar = widget.senha;

  bool get _textoLongo => widget.altura != null;

  OutlineInputBorder _borda(Color cor, [double largura = 1.5]) {
    return OutlineInputBorder(
      // Texto longo: cantos menores, a pílula cortaria as linhas.
      borderRadius: BorderRadius.circular(_textoLongo ? 20 : 30),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    final valor = widget.controller?.text ?? widget.valorInicial ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(widget.rotulo, style: AppTextStyles.fieldLabel),
          ),
          SizedBox(
            height: widget.altura,
            child: TextFormField(
              controller: widget.controller,
              initialValue: widget.controller == null ? valor : null,
              enabled: widget.habilitado,
              readOnly: widget.somenteLeitura,
              obscureText: _ocultar,
              keyboardType: _textoLongo
                  ? TextInputType.multiline
                  : widget.teclado,
              maxLines: _textoLongo ? null : 1,
              expands: _textoLongo,
              textAlignVertical: _textoLongo ? TextAlignVertical.top : null,
              validator: widget.validator,
              inputFormatters: widget.formatadores,
              style: AppTextStyles.fieldValue,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: widget.habilitado
                    ? AppColors.surface
                    : AppColors.surfaceMuted,
                hintText: widget.habilitado ? widget.dica : '—',
                hintStyle: AppTextStyles.formHint,
                helperText: widget.textoAjuda,
                suffixText: widget.sufixo,
                suffixStyle: AppTextStyles.fieldValue,
                prefixIcon: widget.icon == null
                    ? null
                    : Icon(widget.icon, color: AppColors.borderAccent),
                // Sem ícone, o texto não encosta na borda arredondada.
                contentPadding: _textoLongo || widget.icon == null
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                    : null,
                suffixIcon: widget.senha
                    ? IconButton(
                        icon: Icon(
                          _ocultar
                              ? Symbols.visibility
                              : Symbols.visibility_off,
                          color: AppColors.borderAccent,
                        ),
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                      )
                    : null,
                enabledBorder: _borda(AppColors.borderAccent),
                focusedBorder: _borda(AppColors.borderAccent, 2),
                disabledBorder: _borda(const Color.fromRGBO(141, 141, 141, 1)),
                errorBorder: _borda(AppColors.error),
                focusedErrorBorder: _borda(AppColors.error, 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
