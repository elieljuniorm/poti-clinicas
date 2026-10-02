/// Faixa de renda familiar mensal do paciente.
enum FamilyIncome {
  upTo2500('Até 2,5 mil reais'),
  from2500To7000('Entre 2,5 mil reais e 07 mil reais por mês'),
  from7000To22000('Entre 7 mil reais e 22 mil reais por mês'),
  above22000('Acima de 22 mil reais por mês');

  final String label;

  const FamilyIncome(this.label);
}
