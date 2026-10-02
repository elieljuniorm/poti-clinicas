/// Estado civil do paciente.
enum MaritalStatus {
  single('Solteiro (a)'),
  married('Casado (a)'),
  stableUnion('União estável'),
  divorced('Divorciado (a)'),
  widowed('Viúvo (a)');

  final String label;

  const MaritalStatus(this.label);
}
