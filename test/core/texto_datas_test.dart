import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/utils/datas.dart';
import 'package:poti_5f/src/core/utils/texto.dart';

void main() {
  group('Texto', () {
    test('normaliza maiúsculas e acentos', () {
      expect(Texto.normalizar('Antônio ARAÚJO'), 'antonio araujo');
    });

    test('contem ignora acentos, espaços nas pontas e aceita termo vazio', () {
      expect(Texto.contem('Antônio Araújo', ' antonio ara '), isTrue);
      expect(Texto.contem('Antônio Araújo', 'maria'), isFalse);
      expect(Texto.contem('Antônio Araújo', ''), isTrue);
    });
  });

  group('Datas.relativa', () {
    final agora = DateTime(2026, 10, 1, 9);

    test('hoje e ontem', () {
      expect(
        Datas.relativa(DateTime(2026, 10, 1, 13, 30), agora: agora),
        'Hoje, 13:30',
      );
      expect(
        Datas.relativa(DateTime(2026, 9, 30, 15, 0), agora: agora),
        'Ontem, 15:00',
      );
    });

    test('mesmo ano sem o ano; outro ano com o ano', () {
      expect(
        Datas.relativa(DateTime(2026, 2, 12, 16, 20), agora: agora),
        '12/02, 16:20',
      );
      expect(
        Datas.relativa(DateTime(2025, 2, 12, 8, 5), agora: agora),
        '12/02/2025, 08:05',
      );
    });

    test('virada de mês e de ano contam como ontem', () {
      expect(
        Datas.relativa(
          DateTime(2025, 12, 31, 22, 0),
          agora: DateTime(2026, 1, 1, 8),
        ),
        'Ontem, 22:00',
      );
    });
  });
}
