import 'package:flutter/services.dart';

import '../../utils/cep.dart';

/// Máscara de digitação do CEP: aceita só números e insere o traço
/// (`00000-000`), mantendo o cursor depois do mesmo dígito.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = Cep.mascarar(newValue.text);

    // Quantos dígitos havia antes do cursor → mesma posição no texto novo.
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    var digitosAntes = Cep.digitos(newValue.text.substring(0, cursor)).length;
    if (digitosAntes > Cep.tamanho) digitosAntes = Cep.tamanho;

    var posicao = digitosAntes;
    if (digitosAntes > 5) posicao++; // pula o traço

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: posicao),
    );
  }
}
