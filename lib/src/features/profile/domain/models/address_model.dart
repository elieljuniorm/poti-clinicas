class AddressModel {
  final String zipCode;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;

  const AddressModel({
    this.zipCode = '',
    this.street = '',
    this.number = '',
    this.complement = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
  });

  /// Endereço em uma linha, para exibição (ignora partes vazias).
  String get resumo {
    final linha1 = [street, number, complement].where((p) => p.isNotEmpty);
    final linha2 = [neighborhood, city, state].where((p) => p.isNotEmpty);
    return [
      linha1.join(', '),
      linha2.join(' - '),
    ].where((p) => p.isNotEmpty).join(' • ');
  }

  @override
  bool operator ==(Object other) =>
      other is AddressModel &&
      other.zipCode == zipCode &&
      other.street == street &&
      other.number == number &&
      other.complement == complement &&
      other.neighborhood == neighborhood &&
      other.city == city &&
      other.state == state;

  @override
  int get hashCode => Object.hash(
    zipCode,
    street,
    number,
    complement,
    neighborhood,
    city,
    state,
  );
}
