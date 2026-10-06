import 'package:flutter/services.dart';

import '../../utils/moeda.dart';

/// Máscara de digitação em reais: os dígitos entram pela direita como
/// centavos (`1` → `R$ 0,01`, `12345` → `R$ 123,45`). Apagar todos os
/// dígitos deixa o campo vazio. Leia o valor com [Moeda.ler].
class MoedaInputFormatter extends TextInputFormatter {
  /// Limite de dígitos (centavos incluídos): até R$ 9.999.999,99.
  static const maximoDigitos = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > maximoDigitos) {
      digitos = digitos.substring(0, maximoDigitos);
    }
    if (digitos.isEmpty) return TextEditingValue.empty;

    final texto = Moeda.formatar(int.parse(digitos) / 100);
    // O valor cresce pela direita: o cursor fica sempre no fim.
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
