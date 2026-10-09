import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/core/ui/formatters/cep_input_formatter.dart';
import 'package:multiclinica_app/src/core/utils/cep.dart';

void main() {
  group('Cep', () {
    test('mascarar aplica o traço ao que houver, limitado a 8 dígitos', () {
      expect(Cep.mascarar(''), '');
      expect(Cep.mascarar('66017'), '66017');
      expect(Cep.mascarar('660170'), '66017-0');
      expect(Cep.mascarar('66017000'), '66017-000');
      expect(Cep.mascarar('66017-000'), '66017-000');
      expect(Cep.mascarar('66.017-0001'), '66017-000');
    });

    test('formatar só aceita CEP completo', () {
      expect(Cep.formatar('66017000'), '66017-000');
      expect(Cep.formatar('66017-000'), '66017-000');
      expect(Cep.formatar('66017'), isNull);
    });

    test('valido exige o formato 00000-000', () {
      expect(Cep.valido('66017-000'), isTrue);
      expect(Cep.valido('66017000'), isFalse);
      expect(Cep.valido('66017-00'), isFalse);
    });
  });

  group('CepInputFormatter', () {
    final formatter = CepInputFormatter();

    TextEditingValue digitar(String antes, String depois) =>
        formatter.formatEditUpdate(
          TextEditingValue(text: antes),
          TextEditingValue(
            text: depois,
            selection: TextSelection.collapsed(offset: depois.length),
          ),
        );

    test('insere o traço ao passar do 5º dígito', () {
      final valor = digitar('66017', '660170');
      expect(valor.text, '66017-0');
      expect(valor.selection.end, 7);
    });

    test('ignora letras e o que passar de 8 dígitos', () {
      expect(digitar('', '66a017').text, '66017');
      expect(digitar('66017-000', '66017-0001').text, '66017-000');
    });

    test('colar CEP sem traço formata', () {
      expect(digitar('', '66017000').text, '66017-000');
    });
  });
}
