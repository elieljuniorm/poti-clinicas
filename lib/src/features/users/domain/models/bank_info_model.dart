/// Tipo da conta bancária.
enum AccountType {
  checking('Corrente'),
  savings('Poupança');

  final String label;

  const AccountType(this.label);
}

/// Tipo da chave PIX.
enum PixKeyType {
  document('CPF / CNPJ'),
  email('E-mail'),
  phone('Telefone'),
  random('Chave aleatória');

  final String label;

  const PixKeyType(this.label);
}

/// Dados financeiros da equipe (conta para repasse/pagamento e PIX).
/// Cada parte é opcional: conta bancária completa e/ou chave PIX.
class BankInfoModel {
  final String? bank;
  final String? agency;
  final String? account;
  final AccountType? accountType;
  final PixKeyType? pixKeyType;
  final String? pixKey;

  const BankInfoModel({
    this.bank,
    this.agency,
    this.account,
    this.accountType,
    this.pixKeyType,
    this.pixKey,
  });
}
