import '../../../home/domain/models/financial_summary_model.dart';
import '../../domain/models/appointment_history_model.dart';
import '../../domain/models/financial_overview_model.dart';
import '../../domain/models/history_tab.dart';

class HistoryState {
  /// Quantos lançamentos aparecem em "LANÇAMENTOS RECENTES"
  /// antes do "Ver Todos".
  static const lancamentosRecentes = 3;

  final bool isLoading;
  final String? errorMessage;

  /// Aba escolhida no seletor (Atendimentos / Lançamentos).
  final HistoryTab tab;
  final List<AppointmentHistoryModel> appointments;

  /// Todos os lançamentos, do mais recente para o mais antigo.
  final List<FinancialSummaryModel> entries;

  /// "Ver Todos" acionado: mostra todos os lançamentos.
  final bool showAllEntries;

  const HistoryState({
    this.isLoading = false,
    this.errorMessage,
    this.tab = HistoryTab.appointments,
    this.appointments = const [],
    this.entries = const [],
    this.showAllEntries = false,
  });

  /// Totais do card "TOTAL A RECEBER" (sempre de todos os lançamentos).
  FinancialOverviewModel get overview =>
      FinancialOverviewModel.fromEntries(entries);

  /// Lançamentos exibidos: os recentes ou todos.
  List<FinancialSummaryModel> get visibleEntries =>
      showAllEntries ? entries : entries.take(lancamentosRecentes).toList();

  /// Há mais lançamentos do que os recentes (mostra "Ver Todos").
  bool get hasMoreEntries => entries.length > lancamentosRecentes;

  HistoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    HistoryTab? tab,
    List<AppointmentHistoryModel>? appointments,
    List<FinancialSummaryModel>? entries,
    bool? showAllEntries,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
      appointments: appointments ?? this.appointments,
      entries: entries ?? this.entries,
      showAllEntries: showAllEntries ?? this.showAllEntries,
    );
  }
}
