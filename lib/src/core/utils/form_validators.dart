import 'documento.dart';

/// Validações reutilizáveis dos formulários (retornam a mensagem de erro
/// ou `null` quando o valor é válido), no formato do `validator` do Flutter.
abstract final class FormValidators {
  static String? obrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  static String? email(String? valor) {
    final erro = obrigatorio(valor);
    if (erro != null) return erro;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor!.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  /// Celular `(91) 9 9999-9999` ou fixo `(91) 9999-9999`.
  static String? telefone(String? valor) {
    final erro = obrigatorio(valor);
    if (erro != null) return erro;
    final digitos = Documento.digitos(valor!);
    if (digitos.length < 10) return 'Telefone incompleto';
    return null;
  }

  /// Data `DD/MM/AAAA` que exista no calendário e não esteja no futuro.
  /// Vazia só é aceita quando não é [obrigatoria].
  static String? data(String? valor, {bool obrigatoria = false}) {
    if (valor == null || valor.trim().isEmpty) {
      return obrigatoria ? 'Campo obrigatório' : null;
    }
    final partes = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$')
        .firstMatch(valor.trim());
    if (partes == null) return 'Use o formato DD/MM/AAAA';

    final dia = int.parse(partes[1]!);
    final mes = int.parse(partes[2]!);
    final ano = int.parse(partes[3]!);
    final data = DateTime(ano, mes, dia);
    // DateTime "corrige" 31/02 para 03/03: se mudou, a data não existe.
    if (data.day != dia || data.month != mes || ano < 1900) {
      return 'Data inválida';
    }
    if (data.isAfter(DateTime.now())) return 'A data não pode ser futura';
    return null;
  }

  static String? cpf(String? valor) {
    final erro = obrigatorio(valor);
    if (erro != null) return erro;
    if (!Documento.cpfValido(valor!)) return 'CPF inválido';
    return null;
  }

  /// CPF (11 dígitos) ou CNPJ (14 dígitos).
  static String? cpfCnpj(String? valor) {
    final erro = obrigatorio(valor);
    if (erro != null) return erro;
    final digitos = Documento.digitos(valor!);
    if (digitos.length <= Documento.tamanhoCpf) {
      return Documento.cpfValido(digitos) ? null : 'CPF inválido';
    }
    return Documento.cnpjValido(digitos) ? null : 'CNPJ inválido';
  }

  /// Para selects: obriga a escolher uma opção.
  static String? selecao<T>(T? valor) {
    if (valor == null) return 'Selecione uma opção';
    return null;
  }
}
