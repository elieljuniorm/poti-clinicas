import '../../domain/models/finance_dashboard_model.dart';
import '../../domain/models/professional_payout_model.dart';

class FinanceState {
  /// Quantos profissionais aparecem antes do "Ver Todos".
  static const profissionaisVisiveis = 3;

  final bool isLoading;
  final String? errorMessage;
  final FinanceDashboardModel? dashboard;

  /// "Ver Todos" acionado: mostra todos os profissionais.
  final bool showAllProfessionals;

  const FinanceState({
    this.isLoading = false,
    this.errorMessage,
    this.dashboard,
    this.showAllProfessionals = false,
  });

  List<ProfessionalPayoutModel> get _profissionais =>
      dashboard?.professionals ?? const [];

  /// Profissionais exibidos: os primeiros ou todos.
  List<ProfessionalPayoutModel> get visibleProfessionals => showAllProfessionals
      ? _profissionais
      : _profissionais.take(profissionaisVisiveis).toList();

  bool get hasMoreProfessionals =>
      _profissionais.length > profissionaisVisiveis;

  FinanceState copyWith({
    bool? isLoading,
    String? errorMessage,
    FinanceDashboardModel? dashboard,
    bool? showAllProfessionals,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      dashboard: dashboard ?? this.dashboard,
      showAllProfessionals: showAllProfessionals ?? this.showAllProfessionals,
    );
  }
}
