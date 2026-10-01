import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';

/// Select com rótulo acima, no mesmo visual do [ProfileField].
///
/// Abre a lista **dentro do próprio campo**: a borda cresce e envolve as
/// opções, empurrando o resto do formulário para baixo (em vez do menu
/// flutuante padrão do Flutter). Fecha ao escolher uma opção, ao tocar de
/// novo no campo ou ao tocar fora dele.
///
/// Com [habilitado] = `false` o valor fica fixo (fundo cinza, borda suave),
/// mas continua legível (ex.: perfil "Paciente" no cadastro de paciente).
class ProfileDropdownField<T> extends StatefulWidget {
  final String rotulo;
  final List<T> opcoes;
  final String Function(T opcao) rotuloOpcao;
  final T? valor;
  final ValueChanged<T?>? aoMudar;
  final bool habilitado;
  final String dica;
  final String? textoAjuda;
  final String? Function(T?)? validator;

  const ProfileDropdownField({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.rotuloOpcao,
    this.valor,
    this.aoMudar,
    this.habilitado = true,
    this.dica = 'Selecione',
    this.textoAjuda,
    this.validator,
  });

  /// Altura máxima da lista aberta. Com muitas opções (ex.: profissionais),
  /// a lista rola por dentro em vez de crescer sem limite.
  static const double alturaMaximaLista = 240;

  @override
  State<ProfileDropdownField<T>> createState() =>
      _ProfileDropdownFieldState<T>();
}

class _ProfileDropdownFieldState<T> extends State<ProfileDropdownField<T>> {
  static const _duracao = Duration(milliseconds: 200);
  static const _corBordaDesabilitada = Color.fromRGBO(141, 141, 141, 1);

  bool _aberto = false;

  bool get _podeAbrir =>
      widget.habilitado && widget.aoMudar != null && widget.opcoes.isNotEmpty;

  @override
  void didUpdateWidget(covariant ProfileDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Desabilitado no meio (ex.: salvando): a lista fecha.
    if (_aberto && !_podeAbrir) _aberto = false;
  }

  void _alternar() {
    if (!_podeAbrir) return;
    // Fecha o teclado de um campo de texto que estivesse em edição.
    FocusScope.of(context).unfocus();
    setState(() => _aberto = !_aberto);
  }

  void _fechar() {
    if (_aberto) setState(() => _aberto = false);
  }

  void _escolher(FormFieldState<T> campo, T opcao) {
    campo.didChange(opcao);
    widget.aoMudar?.call(opcao);
    setState(() => _aberto = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(widget.rotulo, style: AppTextStyles.fieldLabel),
          ),
          FormField<T>(
            initialValue: widget.valor,
            validator: widget.validator,
            builder: (campo) => _buildCampo(campo),
          ),
        ],
      ),
    );
  }

  Widget _buildCampo(FormFieldState<T> campo) {
    final valor = campo.value;
    final erro = campo.errorText;
    final habilitado = widget.habilitado;

    final corBorda = erro != null
        ? AppColors.error
        : habilitado
        ? AppColors.borderAccent
        : _corBordaDesabilitada;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TapRegion(
          onTapOutside: (_) => _fechar(),
          child: AnimatedContainer(
            duration: _duracao,
            curve: Curves.easeOut,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: habilitado ? AppColors.surface : AppColors.surfaceMuted,
              // Fechado: pílula igual aos campos. Aberto: cantos menores.
              borderRadius: BorderRadius.circular(_aberto ? 20 : 30),
              border: Border.all(color: corBorda, width: _aberto ? 2 : 1.5),
            ),
            // Material transparente: o efeito de toque aparece por cima
            // do fundo do campo.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Cabecalho(
                    texto: valor == null
                        ? widget.dica
                        : widget.rotuloOpcao(valor),
                    temValor: valor != null,
                    aberto: _aberto,
                    habilitado: habilitado,
                    rotulo: widget.rotulo,
                    onTap: _podeAbrir ? _alternar : null,
                  ),
                  AnimatedSize(
                    duration: _duracao,
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _aberto
                        ? _Opcoes<T>(
                            opcoes: widget.opcoes,
                            rotuloOpcao: widget.rotuloOpcao,
                            selecionado: valor,
                            aoEscolher: (opcao) => _escolher(campo, opcao),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (erro != null)
          _TextoAbaixo(texto: erro, cor: AppColors.error)
        else if (widget.textoAjuda != null)
          _TextoAbaixo(texto: widget.textoAjuda!, cor: AppColors.textHint),
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Linha sempre visível: valor escolhido (ou dica) e a seta.
class _Cabecalho extends StatelessWidget {
  final String texto;
  final bool temValor;
  final bool aberto;
  final bool habilitado;
  final String rotulo;
  final VoidCallback? onTap;

  const _Cabecalho({
    required this.texto,
    required this.temValor,
    required this.aberto,
    required this.habilitado,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      expanded: aberto,
      label: rotulo,
      value: texto,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 13, 16, 13),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: temValor
                      ? AppTextStyles.fieldValue
                      : AppTextStyles.formHint,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: aberto ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Symbols.keyboard_arrow_down,
                  color: habilitado
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista de opções dentro da borda do campo.
class _Opcoes<T> extends StatelessWidget {
  final List<T> opcoes;
  final String Function(T opcao) rotuloOpcao;
  final T? selecionado;
  final ValueChanged<T> aoEscolher;

  const _Opcoes({
    required this.opcoes,
    required this.rotuloOpcao,
    required this.selecionado,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: ProfileDropdownField.alturaMaximaLista,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final opcao in opcoes)
            _ItemOpcao(
              texto: rotuloOpcao(opcao),
              selecionado: opcao == selecionado,
              onTap: () => aoEscolher(opcao),
            ),
        ],
      ),
    );
  }
}

class _ItemOpcao extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const _ItemOpcao({
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.fieldValue.copyWith(
              // A opção escolhida aparece destacada ao reabrir a lista.
              fontWeight: selecionado ? FontWeight.bold : FontWeight.w400,
              color: selecionado ? AppColors.borderAccent : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensagem de erro ou ajuda abaixo do campo (como no [InputDecoration]).
class _TextoAbaixo extends StatelessWidget {
  final String texto;
  final Color cor;

  const _TextoAbaixo({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Text(texto, style: TextStyle(fontSize: 12, color: cor)),
    );
  }
}
