import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';

/// Campo de cadastro com rótulo acima.
///
/// Com [habilitado] = `false`, vira só leitura (fundo cinza, borda suave).
/// É assim que a tela de visualização reaproveita o mesmo layout da edição.
class ProfileField extends StatefulWidget {
  final String rotulo;
  final IconData icon;
  final TextEditingController? controller;

  /// Usado quando não há [controller] (modo só leitura).
  final String? valorInicial;
  final bool habilitado;
  final bool senha;
  final TextInputType? teclado;
  final String? textoAjuda;
  final String? Function(String?)? validator;

  /// Máscaras de digitação (ex.: [CepInputFormatter]).
  final List<TextInputFormatter>? formatadores;

  const ProfileField({
    super.key,
    required this.rotulo,
    required this.icon,
    this.controller,
    this.valorInicial,
    this.habilitado = true,
    this.senha = false,
    this.teclado,
    this.textoAjuda,
    this.validator,
    this.formatadores,
  });

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  late bool _ocultar = widget.senha;

  OutlineInputBorder _borda(Color cor, [double largura = 1.5]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
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
          TextFormField(
            controller: widget.controller,
            initialValue: widget.controller == null ? valor : null,
            enabled: widget.habilitado,
            obscureText: _ocultar,
            keyboardType: widget.teclado,
            validator: widget.validator,
            inputFormatters: widget.formatadores,
            style: AppTextStyles.fieldValue,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: widget.habilitado
                  ? AppColors.surface
                  : AppColors.surfaceMuted,
              hintText: widget.habilitado ? null : '—',
              helperText: widget.textoAjuda,
              prefixIcon: Icon(widget.icon, color: AppColors.borderAccent),
              suffixIcon: widget.senha
                  ? IconButton(
                      icon: Icon(
                        _ocultar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
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
        ],
      ),
    );
  }
}
