import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/core/ui/formatters/mask_input_formatter.dart';
import 'package:multiclinica_app/src/core/utils/documento.dart';
import 'package:multiclinica_app/src/core/utils/form_validators.dart';

TextEditingValue _digitar(TextInputFormatter formatter, String texto) {
  return formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    ),
  );
}

void main() {
  group('Documento', () {
    test('CPF: aceita dígitos verificadores certos, com ou sem máscara', () {
      expect(Documento.cpfValido('529.982.247-25'), isTrue);
      expect(Documento.cpfValido('52998224725'), isTrue);
      expect(Documento.cpfValido('529.982.247-24'), isFalse);
      expect(Documento.cpfValido('111.111.111-11'), isFalse);
      expect(Documento.cpfValido('529.982.247'), isFalse);
    });

    test('CNPJ: aceita dígitos verificadores certos', () {
      expect(Documento.cnpjValido('11.222.333/0001-81'), isTrue);
      expect(Documento.cnpjValido('11.222.333/0001-80'), isFalse);
      expect(Documento.cnpjValido('00.000.000/0000-00'), isFalse);
    });
  });

  group('FormValidators', () {
    test('telefone exige DDD + número', () {
      expect(FormValidators.telefone(''), 'Campo obrigatório');
      expect(FormValidators.telefone('(91) 9 9999'), 'Telefone incompleto');
      expect(FormValidators.telefone('(91) 9 9999-9999'), isNull);
      expect(FormValidators.telefone('(91) 3222-1111'), isNull);
    });

    test('data: formato, existência, futuro e obrigatoriedade', () {
      expect(FormValidators.data(''), isNull);
      expect(FormValidators.data('', obrigatoria: true), 'Campo obrigatório');
      expect(FormValidators.data('1/2/2000'), 'Use o formato DD/MM/AAAA');
      expect(FormValidators.data('31/02/2000'), 'Data inválida');
      expect(FormValidators.data('01/01/2999'), 'A data não pode ser futura');
      expect(FormValidators.data('15/03/1990'), isNull);
    });

    test('CPF / CNPJ escolhe a regra pelo tamanho', () {
      expect(FormValidators.cpfCnpj('529.982.247-25'), isNull);
      expect(FormValidators.cpfCnpj('529.982.247-24'), 'CPF inválido');
      expect(FormValidators.cpfCnpj('11.222.333/0001-81'), isNull);
      expect(FormValidators.cpfCnpj('11.222.333/0001-80'), 'CNPJ inválido');
    });

    test('seleção obriga escolher uma opção', () {
      expect(FormValidators.selecao<String>(null), 'Selecione uma opção');
      expect(FormValidators.selecao('a'), isNull);
    });
  });

  group('Máscaras', () {
    test('telefone, data e CPF', () {
      expect(
        _digitar(MaskInputFormatter.telefone(), '91999998888').text,
        '(91) 9 9999-8888',
      );
      expect(
        _digitar(MaskInputFormatter.data(), '15031990').text,
        '15/03/1990',
      );
      expect(
        _digitar(MaskInputFormatter.cpf(), '52998224725').text,
        '529.982.247-25',
      );
    });

    test('máscara parcial não deixa separador sobrando no fim', () {
      expect(_digitar(MaskInputFormatter.telefone(), '91').text, '(91');
      expect(_digitar(MaskInputFormatter.data(), '1503').text, '15/03');
    });

    test('ignora letras e corta o excesso de dígitos', () {
      expect(
        _digitar(MaskInputFormatter.data(), '15a03b19901234').text,
        '15/03/1990',
      );
    });

    test('CPF vira CNPJ ao passar de 11 dígitos', () {
      final formatter = CpfCnpjInputFormatter();
      expect(_digitar(formatter, '52998224725').text, '529.982.247-25');
      expect(_digitar(formatter, '11222333000181').text, '11.222.333/0001-81');
    });

    test('mantém o cursor depois do mesmo dígito', () {
      // Cursor depois do "9" de "(919": vai para depois do "9" em "(91) 9".
      final valor = MaskInputFormatter.telefone().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '(919',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(valor.text, '(91) 9');
      expect(valor.selection.baseOffset, 2);
    });
  });
}
