import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../utils/datas.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// Calendário mensal para escolher **vários dias** (ex.: datas das sessões).
///
/// - Tocar em um dia chama [aoAlternar] com ele (meia-noite); quem usa
///   decide se marca ou desmarca.
/// - Dias selecionados: círculo verde-azulado com número branco.
/// - Dias antes de [primeiroDia] ficam apagados e não respondem ao toque;
///   o mês não volta para antes dele.
/// - Hoje tem um contorno discreto.
class AppMultiDateCalendar extends StatefulWidget {
  final Set<DateTime> selecionadas;
  final ValueChanged<DateTime> aoAlternar;

  /// Primeiro dia que pode ser escolhido (padrão: hoje).
  final DateTime? primeiroDia;

  /// Mês aberto ao montar (padrão: o de [primeiroDia]).
  final DateTime? mesInicial;
  final bool habilitado;

  /// Para os testes: "hoje" fixo.
  final DateTime? hoje;

  const AppMultiDateCalendar({
    super.key,
    required this.selecionadas,
    required this.aoAlternar,
    this.primeiroDia,
    this.mesInicial,
    this.habilitado = true,
    this.hoje,
  });

  @override
  State<AppMultiDateCalendar> createState() => _AppMultiDateCalendarState();
}

class _AppMultiDateCalendarState extends State<AppMultiDateCalendar> {
  late DateTime _mes = _primeiroDoMes(widget.mesInicial ?? _primeiroDia);

  DateTime get _hoje => Datas.dia(widget.hoje ?? DateTime.now());
  DateTime get _primeiroDia => Datas.dia(widget.primeiroDia ?? _hoje);

  static DateTime _primeiroDoMes(DateTime data) =>
      DateTime(data.year, data.month);

  bool get _podeVoltar => _mes.isAfter(_primeiroDoMes(_primeiroDia));

  void _mudarMes(int delta) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final selecionadas = widget.selecionadas.map(Datas.dia).toSet();
    final diasNoMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    // DateTime.weekday: segunda = 1 … domingo = 7 → coluna com domingo = 0.
    final colunaInicial = _mes.weekday % 7;

    final celulas = <DateTime?>[
      for (var i = 0; i < colunaInicial; i++) null,
      for (var d = 1; d <= diasNoMes; d++) DateTime(_mes.year, _mes.month, d),
    ];
    while (celulas.length % 7 != 0) {
      celulas.add(null);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // ---------- Mês e navegação ----------
          Row(
            children: [
              IconButton(
                tooltip: 'Mês anterior',
                onPressed: _podeVoltar ? () => _mudarMes(-1) : null,
                icon: const Icon(Symbols.chevron_left),
                color: AppColors.borderAccent,
              ),
              Expanded(
                child: Text(
                  Datas.mesAno(_mes),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Próximo mês',
                onPressed: () => _mudarMes(1),
                icon: const Icon(Symbols.chevron_right),
                color: AppColors.borderAccent,
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ---------- Dias da semana ----------
          Row(
            children: [
              for (final dia in Datas.diasDaSemana)
                Expanded(
                  child: Text(
                    dia,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ---------- Dias ----------
          for (var semana = 0; semana < celulas.length ~/ 7; semana++)
            Row(
              children: [
                for (final dia in celulas.skip(semana * 7).take(7))
                  Expanded(
                    child: dia == null
                        ? const SizedBox(height: _Dia.tamanho + 8)
                        : _Dia(
                            dia: dia,
                            selecionado: selecionadas.contains(dia),
                            hoje: dia == _hoje,
                            disponivel:
                                widget.habilitado &&
                                !dia.isBefore(_primeiroDia),
                            onTap: () => widget.aoAlternar(dia),
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _Dia extends StatelessWidget {
  static const double tamanho = 40;

  final DateTime dia;
  final bool selecionado;
  final bool hoje;
  final bool disponivel;
  final VoidCallback onTap;

  const _Dia({
    required this.dia,
    required this.selecionado,
    required this.hoje,
    required this.disponivel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corTexto = selecionado
        ? AppColors.surface
        : disponivel
        ? AppColors.textPrimary
        : AppColors.textHint.withValues(alpha: 0.5);

    return Semantics(
      button: true,
      enabled: disponivel,
      selected: selecionado,
      label: Datas.data(dia),
      // excludeSemantics esconde o toque do InkWell: repassa aqui.
      onTap: disponivel ? onTap : null,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Material(
            color: selecionado ? AppColors.borderAccent : Colors.transparent,
            shape: CircleBorder(
              side: hoje && !selecionado
                  ? const BorderSide(color: AppColors.borderAccent)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: disponivel ? onTap : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: tamanho,
                height: tamanho,
                child: Center(
                  child: Text(
                    '${dia.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selecionado
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: corTexto,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
