/// Categorias de paciente exibidas ao lado do perfil.
enum PatientCategory {
  pediatric('Pediatria'),
  adult('Adulto'),
  elderly('Idoso');

  final String label;

  const PatientCategory(this.label);
}
