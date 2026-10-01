import 'package:flutter/services.dart';

import '../../utils/documento.dart';

/// Máscara de digitação só com números. Cada `#` da [mascara] é um dígito;
/// os outros caracteres são inseridos sozinhos (ex.: `(##) # ####-####`).
/// O cursor fica depois do mesmo dígito em que estava.
class MaskInputFormatter extends TextInputFormatter {
  final String mascara;

  MaskInputFormatter(this.mascara);

  /// `(91) 9 9999-9999`
  factory MaskInputFormatter.telefone() =>
      MaskInputFormatter('(##) # ####-####');

  /// `DD/MM/AAAA`
  factory MaskInputFormatter.data() => MaskInputFormatter('##/##/####');

  /// `000.000.000-00`
  factory MaskInputFormatter.cpf() => MaskInputFormatter('###.###.###-##');

  int get _maxDigitos => '#'.allMatches(mascara).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return aplicar(mascara, newValue, _maxDigitos);
  }

  /// Aplica a [mascara] ao [valor], preservando a posição do cursor.
  static TextEditingValue aplicar(
    String mascara,
    TextEditingValue valor,
    int maxDigitos,
  ) {
    var digitos = Documento.digitos(valor.text);
    if (digitos.length > maxDigitos) digitos = digitos.substring(0, maxDigitos);

    // Quantos dígitos havia antes do cursor → mesma posição no texto novo.
    final cursor = valor.selection.end.clamp(0, valor.text.length);
    final digitosAntes = Documento.digitos(valor.text.substring(0, cursor))
        .length
        .clamp(0, digitos.length);

    final buffer = StringBuffer();
    var usados = 0;
    var posicao = 0;
    for (final caractere in mascara.split('')) {
      if (usados == digitos.length) break;
      if (caractere == '#') {
        buffer.write(digitos[usados++]);
      } else {
        buffer.write(caractere);
      }
      if (usados <= digitosAntes) posicao = buffer.length;
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: posicao),
    );
  }
}

/// Máscara de CPF (`000.000.000-00`) que vira CNPJ (`00.000.000/0000-00`)
/// quando passa de 11 dígitos.
class CpfCnpjInputFormatter extends TextInputFormatter {
  static const _cpf = '###.###.###-##';
  static const _cnpj = '##.###.###/####-##';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = Documento.digitos(newValue.text).length;
    return digitos <= Documento.tamanhoCpf
        ? MaskInputFormatter.aplicar(_cpf, newValue, Documento.tamanhoCpf)
        : MaskInputFormatter.aplicar(_cnpj, newValue, Documento.tamanhoCnpj);
  }
}
