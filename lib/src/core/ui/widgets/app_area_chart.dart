import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/moeda.dart';
import '../theme/app_colors.dart';

/// Um ponto do [AppAreaChart]: rótulo do eixo X e valor.
class AppChartPoint {
  final String rotulo;
  final double valor;

  const AppChartPoint(this.rotulo, this.valor);
}

/// Gráfico de área de uma série (ex.: faturamento da semana).
///
/// - Eixo Y com números redondos (0, 300, 600…) calculados a partir do
///   maior valor; grade discreta de 1px.
/// - Linha de 2px e pontos de 8px com anel na cor do fundo.
/// - Tocar ou arrastar mostra a linha-guia e o valor do ponto mais próximo;
///   tocar fora esconde.
/// - Leitores de tela recebem [descricao] com todos os valores.
class AppAreaChart extends StatefulWidget {
  final List<AppChartPoint> pontos;

  /// Nome da série para acessibilidade (ex.: "Faturamento da semana").
  final String descricao;

  /// Texto do valor na caixa do toque. Padrão: em reais.
  final String Function(double valor) formatarValor;
  final Color cor;

  /// Opacidade do preenchimento sob a linha.
  final double opacidadeArea;
  final double altura;

  /// Avisa o ponto tocado (índice em [pontos]) ou `null` ao limpar.
  /// Use para abrir o detalhe do dia.
  final ValueChanged<int?>? aoSelecionar;

  const AppAreaChart({
    super.key,
    required this.pontos,
    required this.descricao,
    this.formatarValor = Moeda.formatar,
    this.cor = AppColors.chartPrimary,
    this.opacidadeArea = 0.7,
    this.altura = 300,
    this.aoSelecionar,
  });

  /// Topo do eixo Y e distância entre as linhas de grade, com números
  /// redondos: maior valor 1330 → (1500, 300).
  static (double topo, double passo) escala(double maior, {int divisoes = 5}) {
    if (maior <= 0) return (divisoes.toDouble(), 1);

    final bruto = maior / divisoes;
    final magnitude = math
        .pow(10, (math.log(bruto) / math.ln10).floor())
        .toDouble();
    final normal = bruto / magnitude;
    final redondo = normal <= 1
        ? 1.0
        : normal <= 2
        ? 2.0
        : normal <= 2.5
        ? 2.5
        : normal <= 3
        ? 3.0
        : normal <= 5
        ? 5.0
        : 10.0;
    final passo = redondo * magnitude;
    return ((maior / passo).ceil() * passo, passo);
  }

  @override
  State<AppAreaChart> createState() => _AppAreaChartState();
}

class _AppAreaChartState extends State<AppAreaChart> {
  int? _selecionado;

  /// Estilo de texto do tema (fonte do app). O [CustomPainter] não herda
  /// sozinho, então os rótulos partem dele.
  TextStyle _estiloBase(BuildContext context) =>
      DefaultTextStyle.of(context).style;

  void _selecionarEm(double x, double largura, TextStyle estiloBase) {
    final pontos = widget.pontos;
    if (pontos.isEmpty) return;
    final indice = _ChartGeometry.indiceMaisProximo(
      x: x,
      largura: largura,
      quantidade: pontos.length,
      margemEsquerda: _ChartGeometry.margemEsquerda(widget.pontos, estiloBase),
    );
    if (indice == _selecionado) return;
    setState(() => _selecionado = indice);
    widget.aoSelecionar?.call(indice);
  }

  void _limpar() {
    if (_selecionado == null) return;
    setState(() => _selecionado = null);
    widget.aoSelecionar?.call(null);
  }

  String get _textoAcessivel {
    final valores = widget.pontos
        .map((p) => '${p.rotulo}: ${widget.formatarValor(p.valor)}')
        .join(', ');
    return '${widget.descricao}. $valores';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _textoAcessivel,
      excludeSemantics: true,
      child: TapRegion(
        onTapOutside: (_) => _limpar(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largura = constraints.maxWidth;
            final estiloBase = _estiloBase(context);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) =>
                  _selecionarEm(d.localPosition.dx, largura, estiloBase),
              // No arraste o toque é descartado: seleciona já no início.
              onHorizontalDragStart: (d) =>
                  _selecionarEm(d.localPosition.dx, largura, estiloBase),
              onHorizontalDragUpdate: (d) =>
                  _selecionarEm(d.localPosition.dx, largura, estiloBase),
              child: CustomPaint(
                size: Size(largura, widget.altura),
                painter: _AreaChartPainter(
                  pontos: widget.pontos,
                  estiloBase: estiloBase,
                  cor: widget.cor,
                  opacidadeArea: widget.opacidadeArea,
                  selecionado: _selecionado,
                  formatarValor: widget.formatarValor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// Desenho
// ============================================================

/// Medidas compartilhadas entre o desenho e o toque.
abstract final class _ChartGeometry {
  static const estiloEixo = TextStyle(fontSize: 11, color: AppColors.textHint);
  static const espacoRotuloY = 8.0;
  static const alturaEixoX = 22.0;
  static const margemTopo = 8.0;

  /// Folga nas pontas para o ponto e o rótulo do X não serem cortados.
  static const folgaLateral = 6.0;

  static double margemEsquerda(
    List<AppChartPoint> pontos,
    TextStyle estiloBase,
  ) {
    final maior = pontos.fold<double>(0, (m, p) => math.max(m, p.valor));
    final (topo, _) = AppAreaChart.escala(maior);
    final rotulo = TextPainter(
      text: TextSpan(
        text: Moeda.formatarInteiro(topo),
        style: estiloBase.merge(estiloEixo),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return rotulo.width + espacoRotuloY;
  }

  static double xDoPonto(
    int i,
    int quantidade,
    double esquerda,
    double largura,
  ) {
    final inicio = esquerda + folgaLateral;
    final fim = largura - folgaLateral;
    if (quantidade == 1) return (inicio + fim) / 2;
    return inicio + (fim - inicio) * i / (quantidade - 1);
  }

  static int indiceMaisProximo({
    required double x,
    required double largura,
    required int quantidade,
    required double margemEsquerda,
  }) {
    var melhor = 0;
    var distancia = double.infinity;
    for (var i = 0; i < quantidade; i++) {
      final d = (xDoPonto(i, quantidade, margemEsquerda, largura) - x).abs();
      if (d < distancia) {
        distancia = d;
        melhor = i;
      }
    }
    return melhor;
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<AppChartPoint> pontos;
  final TextStyle estiloBase;
  final Color cor;
  final double opacidadeArea;
  final int? selecionado;
  final String Function(double valor) formatarValor;

  _AreaChartPainter({
    required this.pontos,
    required this.estiloBase,
    required this.cor,
    required this.opacidadeArea,
    required this.selecionado,
    required this.formatarValor,
  });

  TextPainter _texto(String texto, TextStyle estilo) => TextPainter(
    text: TextSpan(text: texto, style: estiloBase.merge(estilo)),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final maior = pontos.fold<double>(0, (m, p) => math.max(m, p.valor));
    final (topo, passo) = AppAreaChart.escala(maior);

    final esquerda = _ChartGeometry.margemEsquerda(pontos, estiloBase);
    final base = size.height - _ChartGeometry.alturaEixoX;
    final alturaUtil = base - _ChartGeometry.margemTopo;
    double yDoValor(double valor) => base - alturaUtil * (valor / topo);

    // ---------- Grade e rótulos do eixo Y ----------
    final grade = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    for (var valor = 0.0; valor <= topo + passo / 2; valor += passo) {
      final y = yDoValor(valor);
      canvas.drawLine(Offset(esquerda, y), Offset(size.width, y), grade);
      final rotulo = _texto(
        Moeda.formatarInteiro(valor),
        _ChartGeometry.estiloEixo,
      );
      rotulo.paint(
        canvas,
        Offset(
          esquerda - _ChartGeometry.espacoRotuloY - rotulo.width,
          y - rotulo.height / 2,
        ),
      );
    }

    if (pontos.isEmpty) return;

    final posicoes = [
      for (var i = 0; i < pontos.length; i++)
        Offset(
          _ChartGeometry.xDoPonto(i, pontos.length, esquerda, size.width),
          yDoValor(pontos[i].valor),
        ),
    ];

    // ---------- Rótulos do eixo X ----------
    for (var i = 0; i < pontos.length; i++) {
      final rotulo = _texto(pontos[i].rotulo, _ChartGeometry.estiloEixo);
      final x = (posicoes[i].dx - rotulo.width / 2).clamp(
        esquerda - _ChartGeometry.folgaLateral,
        size.width - rotulo.width,
      );
      rotulo.paint(canvas, Offset(x, base + 6));
    }

    // ---------- Área, linha e pontos ----------
    final linha = Path()..moveTo(posicoes.first.dx, posicoes.first.dy);
    for (final p in posicoes.skip(1)) {
      linha.lineTo(p.dx, p.dy);
    }
    final area = Path.from(linha)
      ..lineTo(posicoes.last.dx, base)
      ..lineTo(posicoes.first.dx, base)
      ..close();

    canvas.drawPath(
      area,
      Paint()..color = cor.withValues(alpha: opacidadeArea),
    );
    canvas.drawPath(
      linha,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final selecionado = this.selecionado;
    if (selecionado != null) {
      final x = posicoes[selecionado].dx;
      canvas.drawLine(
        Offset(x, _ChartGeometry.margemTopo),
        Offset(x, base),
        Paint()
          ..color = AppColors.textHint
          ..strokeWidth = 1,
      );
    }

    final anel = Paint()..color = AppColors.surface;
    final ponto = Paint()..color = cor;
    for (var i = 0; i < posicoes.length; i++) {
      final raio = i == selecionado ? 6.0 : 4.0;
      canvas.drawCircle(posicoes[i], raio + 2, anel);
      canvas.drawCircle(posicoes[i], raio, ponto);
    }

    if (selecionado != null) {
      _desenharCaixaValor(canvas, size, posicoes[selecionado], selecionado);
    }
  }

  /// Caixa escura acima do ponto com "Dia · valor".
  void _desenharCaixaValor(Canvas canvas, Size size, Offset ponto, int i) {
    final texto = _texto(
      '${pontos[i].rotulo} · ${formatarValor(pontos[i].valor)}',
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
      ),
    );
    const folga = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final largura = texto.width + folga.horizontal;
    final altura = texto.height + folga.vertical;

    // Acima do ponto; se não couber, abaixo. Nunca sai pelas laterais.
    final esquerda = (ponto.dx - largura / 2).clamp(0.0, size.width - largura);
    var topo = ponto.dy - altura - 12;
    if (topo < 0) topo = ponto.dy + 12;

    final caixa = RRect.fromRectAndRadius(
      Rect.fromLTWH(esquerda, topo, largura, altura),
      const Radius.circular(8),
    );
    canvas.drawRRect(caixa, Paint()..color = AppColors.chartTooltip);
    texto.paint(canvas, Offset(esquerda + folga.left, topo + folga.top));
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter old) =>
      old.pontos != pontos ||
      old.estiloBase != estiloBase ||
      old.selecionado != selecionado ||
      old.cor != cor ||
      old.opacidadeArea != opacidadeArea;
}
