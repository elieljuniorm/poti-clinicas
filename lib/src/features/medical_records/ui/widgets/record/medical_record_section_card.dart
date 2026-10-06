import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/utils/datas.dart';
import '../../../domain/models/medical_record_content.dart';
import '../../../domain/models/medical_record_model.dart';

/// Uma seção do prontuário (só leitura): data de criação, da última
/// modificação e o texto de cada campo da [secao]. O lápis abre a edição
/// ([aoEditar]); sem ele, o prontuário não pode ser editado.
class MedicalRecordSectionCard extends StatelessWidget {
  final MedicalRecordSection secao;
  final MedicalRecordModel record;
  final VoidCallback? aoEditar;

  const MedicalRecordSectionCard({
    super.key,
    required this.secao,
    required this.record,
    this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    final aoEditar = this.aoEditar;

    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criação - ${Datas.data(record.createdAt)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.borderAccent,
                      ),
                    ),
                    if (record.foiModificado)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Última modificação - '
                          '${Datas.data(record.updatedAt)} às '
                          '${Datas.hora(record.updatedAt.hour, record.updatedAt.minute)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Mantém a altura da linha mesmo sem o lápis.
              SizedBox(
                height: 48,
                child: aoEditar == null
                    ? null
                    : IconButton(
                        tooltip: 'Editar ${secao.label.toLowerCase()}',
                        icon: const Icon(
                          Symbols.edit,
                          color: AppColors.chipSelected,
                        ),
                        onPressed: aoEditar,
                      ),
              ),
            ],
          ),
          for (final campo in secao.campos) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Divider(height: 16, color: Colors.grey[200]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
              child: _Campo(campo: campo, texto: record.content[campo]),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Campo extends StatelessWidget {
  final MedicalRecordField campo;
  final String texto;

  const _Campo({required this.campo, required this.texto});

  @override
  Widget build(BuildContext context) {
    final vazio = texto.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          campo.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.borderAccent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          vazio ? 'Não informado' : texto,
          textAlign: vazio ? TextAlign.start : TextAlign.justify,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: vazio ? AppColors.textHint : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
