import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/new_invoice_model.dart';
import '../domain/repositories/finance_repository.dart';
import '../ui/states/new_invoice_state.dart';
import 'finance_controller.dart';

/// Lança a fatura (tela "Novo Lançamento" e finalização da pré-fatura).
class NewInvoiceController extends Notifier<NewInvoiceState> {
  FinanceRepository get _repository => ref.read(financeRepositoryProvider);

  @override
  NewInvoiceState build() {
    return const NewInvoiceInitial();
  }

  Future<void> lancar(NewInvoiceModel fatura) async {
    state = const NewInvoiceSaving();

    try {
      final creditos = await _repository.lancarFatura(fatura);
      if (!ref.mounted) return;

      // O painel some com a pré-fatura e mostra o novo pendente do mês.
      atualizarFinanceiro(ref);

      state = NewInvoiceSuccess(creditos);
    } catch (e) {
      if (!ref.mounted) return;
      state = NewInvoiceError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o estado volta a [NewInvoiceInitial] sempre que
/// a tela é fechada e aberta de novo.
final newInvoiceControllerProvider =
    NotifierProvider.autoDispose<NewInvoiceController, NewInvoiceState>(
      NewInvoiceController.new,
    );
