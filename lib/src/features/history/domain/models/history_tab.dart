/// Abas do Histórico (seletor do topo).
enum HistoryTab {
  appointments('Atendimentos'),
  entries('Lançamentos');

  final String label;

  const HistoryTab(this.label);
}
