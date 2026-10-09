import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/core/utils/datas.dart';
import 'package:multiclinica_app/src/core/utils/documento.dart';

void main() {
  test('data, mês/ano e hora', () {
    expect(Datas.data(DateTime(2025, 7, 5)), '05/07/2025');
    expect(Datas.mesAno(DateTime(2025, 7, 15)), 'Julho 2025');
    expect(Datas.mesAno(DateTime(2026, 3)), 'Março 2026');
    expect(Datas.hora(9, 5), '09:05');
  });

  test('dia tira o horário', () {
    expect(Datas.dia(DateTime(2025, 7, 15, 14, 30)), DateTime(2025, 7, 15));
  });

  test('CPF mascarado mostra só o final', () {
    expect(Documento.mascararCpf('123.456.789-00'), '***.***.789-00');
    expect(Documento.mascararCpf('12345678900'), '***.***.789-00');
    // Sem 11 dígitos: devolve como veio.
    expect(Documento.mascararCpf('123'), '123');
  });
}
