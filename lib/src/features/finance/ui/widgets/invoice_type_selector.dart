import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../domain/models/new_invoice_model.dart';

/// "TIPO DE ATENDIMENTO" da fatura: três cards lado a lado com ícone e
/// nome. O escolhido fica preenchido. Funciona dentro de um [Form]: sem
/// escolha, mostra o erro ao validar.
class InvoiceTypeSelector extends StatelessWidget {
  final InvoiceType? selecionado;
  final ValueChanged<InvoiceType> aoSelecionar;
  final bool habilitado;

  const InvoiceTypeSelector({
    super.key,
    required this.selecionado,
    required this.aoSelecionar,
    this.habilitado = true,
  });

  static IconData iconeDe(InvoiceType tipo) => switch (tipo) {
    InvoiceType.homePackage => Symbols.real_estate_agent,
    InvoiceType.clinicPackage => Symbols.physical_therapy,
    InvoiceType.single => Symbols.handshake,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text('TIPO DE ATENDIMENTO', style: AppTextStyles.fieldLabel),
          ),
          FormField<InvoiceType>(
            initialValue: selecionado,
            validator: (tipo) =>
                tipo == null ? 'Selecione o tipo de atendimento' : null,
            builder: (campo) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IntrinsicHeight: os três cards com a mesma altura, mesmo
                // quando um nome quebra em duas linhas.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final tipo in InvoiceType.values) ...[
                        Expanded(
                          child: _Opcao(
                            tipo: tipo,
                            ativo: tipo == selecionado,
                            erro: campo.hasError,
                            onTap: habilitado
                                ? () {
                                    campo.didChange(tipo);
                                    aoSelecionar(tipo);
                                  }
                                : null,
                          ),
                        ),
                        if (tipo != InvoiceType.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                if (campo.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Text(
                      campo.errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Opcao extends StatelessWidget {
  final InvoiceType tipo;
  final bool ativo;
  final bool erro;
  final VoidCallback? onTap;

  const _Opcao({
    required this.tipo,
    required this.ativo,
    required this.erro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corConteudo = ativo ? AppColors.textOnDark : AppColors.borderAccent;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: erro ? AppColors.error : AppColors.borderAccent,
        width: 1.5,
      ),
    );

    return Semantics(
      button: true,
      selected: ativo,
      label: tipo.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: ativo ? AppColors.borderAccent : AppColors.surface,
        shape: forma,
        child: InkWell(
          onTap: onTap,
          customBorder: forma,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(InvoiceTypeSelector.iconeDe(tipo), color: corConteudo),
                const SizedBox(height: 6),
                Text(
                  tipo.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: corConteudo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
