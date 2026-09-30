/// Contrato de serviços do paciente.
class ContractModel {
  final String name;
  final String startDate;
  final String endDate;
  final bool active;

  /// Nome do arquivo do contrato (ex.: "Contrato de Serviços.pdf").
  final String? fileName;

  const ContractModel({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.active,
    this.fileName,
  });
}
