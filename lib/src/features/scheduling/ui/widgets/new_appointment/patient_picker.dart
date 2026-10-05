import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/ui/widgets/app_search_field.dart';
import '../../../../../core/utils/documento.dart';
import '../../../../../core/utils/texto.dart';
import '../../../../users/domain/models/user_model.dart';
import 'remove_circle_button.dart';

/// Campo "PACIENTE": busca pelo nome entre os [pacientes] e, ao escolher,
/// mostra o card do paciente selecionado com o "x" para remover.
/// Digitar de novo com alguém selecionado permite trocar direto.
class PatientPicker extends StatefulWidget {
  final List<UserModel> pacientes;
  final UserModel? selecionado;
  final ValueChanged<UserModel> aoSelecionar;
  final VoidCallback aoRemover;

  /// Mensagem de erro abaixo (ex.: "Selecione um paciente").
  final String? erro;
  final bool habilitado;

  /// Quantas sugestões aparecem no máximo.
  static const maximoSugestoes = 5;

  const PatientPicker({
    super.key,
    required this.pacientes,
    required this.selecionado,
    required this.aoSelecionar,
    required this.aoRemover,
    this.erro,
    this.habilitado = true,
  });

  @override
  State<PatientPicker> createState() => _PatientPickerState();
}

class _PatientPickerState extends State<PatientPicker> {
  final _busca = TextEditingController();
  String _termo = '';

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  List<UserModel> get _sugestoes {
    if (_termo.trim().isEmpty) return const [];
    return widget.pacientes
        .where((p) => Texto.contem(p.name, _termo))
        .take(PatientPicker.maximoSugestoes)
        .toList();
  }

  void _escolher(UserModel paciente) {
    _busca.clear();
    setState(() => _termo = '');
    FocusScope.of(context).unfocus();
    widget.aoSelecionar(paciente);
  }

  @override
  Widget build(BuildContext context) {
    final selecionado = widget.selecionado;
    final buscando = _termo.trim().isNotEmpty;
    final sugestoes = _sugestoes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IgnorePointer(
          ignoring: !widget.habilitado,
          child: AppSearchField(
            controller: _busca,
            dica: 'Buscar paciente por nome',
            destaque: true,
            aoBuscar: (texto) => setState(() => _termo = texto),
          ),
        ),
        if (widget.erro != null && !buscando && selecionado == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              widget.erro!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        if (buscando) ...[
          const SizedBox(height: 8),
          _Sugestoes(sugestoes: sugestoes, aoEscolher: _escolher),
        ],
        if (selecionado != null) ...[
          const SizedBox(height: 12),
          _PacienteSelecionado(
            paciente: selecionado,
            aoRemover: widget.habilitado ? widget.aoRemover : null,
          ),
        ],
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

String? _cpf(UserModel paciente) {
  final documento = paciente.document;
  if (documento == null || documento.isEmpty) return null;
  return 'CPF: ${Documento.mascararCpf(documento)}';
}

class _Sugestoes extends StatelessWidget {
  final List<UserModel> sugestoes;
  final ValueChanged<UserModel> aoEscolher;

  const _Sugestoes({required this.sugestoes, required this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: sugestoes.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum paciente encontrado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textHint),
              ),
            )
          : Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (final paciente in sugestoes) ...[
                    InkWell(
                      onTap: () => aoEscolher(paciente),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                paciente.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_cpf(paciente) != null)
                              Text(
                                _cpf(paciente)!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (paciente != sugestoes.last)
                      Divider(height: 1, color: Colors.grey[200]),
                  ],
                ],
              ),
            ),
    );
  }
}

class _PacienteSelecionado extends StatelessWidget {
  final UserModel paciente;
  final VoidCallback? aoRemover;

  const _PacienteSelecionado({required this.paciente, this.aoRemover});

  @override
  Widget build(BuildContext context) {
    final cpf = _cpf(paciente);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      paciente.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.actionCardBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Selecionado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.borderAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cpf != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    cpf,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          RemoveCircleButton(dica: 'Remover paciente', onTap: aoRemover),
        ],
      ),
    );
  }
}
