import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../../../core/utils/datas.dart';
import '../../domain/models/medical_record_summary_model.dart';
import 'medical_record_status_tag.dart';

/// Card de um paciente no prontuário: nome, última sessão, status,
/// especialidade e a ação do registro.
///
/// Sem prontuário criado, a ação é "Criar Registro" ([aoCriar]);
/// com prontuário, "Ver / Editar Registro" ([aoAbrir]).
class MedicalRecordCard extends StatelessWidget {
  final MedicalRecordSummaryModel record;
  final VoidCallback aoCriar;
  final VoidCallback aoAbrir;

  const MedicalRecordCard({
    super.key,
    required this.record,
    required this.aoCriar,
    required this.aoAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final ultimaSessao = record.lastSession;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nome, última sessão e status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.patientName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ultimaSessao == null
                            ? 'Nenhuma sessão realizada'
                            : 'Última sessão: ${Datas.relativa(ultimaSessao)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: MedicalRecordStatusTag(status: record.status),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Especialidade e ação do registro
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    record.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.borderAccent,
                    ),
                  ),
                ),
                _AcaoRegistro(
                  texto: record.hasRecord
                      ? 'Ver / Editar Registro'
                      : 'Criar Registro',
                  onTap: record.hasRecord ? aoAbrir : aoCriar,
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

class _AcaoRegistro extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _AcaoRegistro({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.borderAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Symbols.open_in_new, size: 22, color: AppColors.linkIcon),
        ],
      ),
    );
  }
}
