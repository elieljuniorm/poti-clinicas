import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/formatters/moeda_input_formatter.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_quantity_stepper.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_select_field.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/moeda.dart';
import '../../../profile/ui/widgets/profile_field.dart';
import '../../../scheduling/ui/widgets/new_appointment/patient_picker.dart';
import '../../../users/application/users_controller.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_role.dart';
import '../../application/finance_controller.dart';
import '../../application/new_invoice_controller.dart';
import '../../domain/models/new_invoice_model.dart';
import '../../domain/models/pre_invoice_model.dart';
import '../states/new_invoice_state.dart';
import '../widgets/invoice_type_selector.dart';
import '../widgets/patient_credits_info.dart';
import '../widgets/pre_invoice_card.dart';

/// Lançamento de fatura do Financeiro, em dois modos:
///
/// - **Novo Lançamento** (sem [preInvoiceId]): paciente que ainda não tem
///   atendimento. Todas as sessões viram créditos de agendamento, usados
///   quando o atendimento for criado na Agenda.
/// - **Finalizar pré-fatura** (com [preInvoiceId]): paciente, profissional
///   e sessões vêm do atendimento e ficam travados. Dá para faturar mais
///   sessões do que as agendadas: as extras viram créditos.
class NewInvoiceScreen extends ConsumerStatefulWidget {
  final String? preInvoiceId;

  const NewInvoiceScreen({super.key, this.preInvoiceId});

  @override
  ConsumerState<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends ConsumerState<NewInvoiceScreen> {
  static const _maximoSessoes = 99;

  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _totalController = TextEditingController();
  final _percentualController = TextEditingController();
  final _observacoesController = TextEditingController();

  /// Guardada ao abrir: o painel recarrega sem ela depois de lançar.
  PreInvoiceModel? _preFatura;

  UserModel? _paciente;
  String? _profissionalId;
  InvoiceType? _tipo;
  PaymentMethod? _pagamento;

  /// `null` até mexer no contador: vale o mínimo.
  int? _sessoesEscolhidas;

  /// Depois de tentar salvar, o paciente vazio passa a mostrar erro.
  bool _tentouSalvar = false;

  bool get _finalizando => widget.preInvoiceId != null;

  /// Não dá para faturar menos sessões do que as já agendadas.
  int get _minimoSessoes => _preFatura?.sessions ?? 1;

  int get _sessoes => _sessoesEscolhidas ?? _minimoSessoes;

  @override
  void initState() {
    super.initState();
    _valorController.addListener(_atualizarTotal);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _totalController.dispose();
    _percentualController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  /// TOTAL = valor da sessão × sessões.
  void _atualizarTotal() {
    final valor = Moeda.ler(_valorController.text);
    _totalController.text = valor == null
        ? ''
        : Moeda.formatar(valor * _sessoes);
  }

  void _mudarSessoes(int sessoes) {
    setState(() => _sessoesEscolhidas = sessoes);
    _atualizarTotal();
  }

  static String? _validarValor(String? texto) {
    final valor = Moeda.ler(texto ?? '');
    if (valor == null || valor <= 0) return 'Informe o valor';
    return null;
  }

  static String? _validarPercentual(String? texto) {
    if (texto == null || texto.isEmpty) return null;
    if (int.parse(texto) > 100) return 'Máximo 100%';
    return null;
  }

  void _salvar(Map<String, String> profissionais) {
    setState(() => _tentouSalvar = true);
    final camposOk = _formKey.currentState!.validate();

    final preFatura = _preFatura;
    final pacienteId = preFatura?.patientId ?? _paciente?.id;
    final profissionalId = preFatura?.professionalId ?? _profissionalId;
    if (!camposOk || pacienteId == null || profissionalId == null) return;

    final percentual = _percentualController.text;
    ref
        .read(newInvoiceControllerProvider.notifier)
        .lancar(
          NewInvoiceModel(
            preInvoiceId: preFatura?.id,
            patientId: pacienteId,
            patientName: preFatura?.patientName ?? _paciente!.name,
            professionalId: profissionalId,
            professionalName:
                preFatura?.professionalName ??
                profissionais[profissionalId] ??
                '',
            type: _tipo!,
            sessions: _sessoes,
            sessionValue: Moeda.ler(_valorController.text)!,
            paymentMethod: _pagamento!,
            percentage: percentual.isEmpty ? null : int.parse(percentual),
            notes: _observacoesController.text,
          ),
        );
  }

  String _mensagemSucesso(int creditos) {
    final paciente = _preFatura?.patientName ?? _paciente?.name ?? 'paciente';
    final base = 'Fatura de $paciente lançada';
    if (creditos == 0) return base;
    final gerados = creditos == 1 ? 'gerado' : 'gerados';
    return '$base. ${PatientCreditsInfo.creditos(creditos)} $gerados';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NewInvoiceState>(newInvoiceControllerProvider, (previous, next) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior.
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (next is NewInvoiceSuccess) {
        messenger.showSnackBar(
          SnackBar(content: Text(_mensagemSucesso(next.credits))),
        );
        context.goNamed('financeiro');
      }
      if (next is NewInvoiceError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final financeiro = ref.watch(financeControllerProvider);
    if (_finalizando) {
      _preFatura ??= ref
          .read(financeControllerProvider.notifier)
          .preFatura(widget.preInvoiceId!);
    }

    return AppScaffold(
      titulo: _finalizando ? 'Finalizar Pré-fatura' : 'Novo Lançamento',
      rotaAtual: _finalizando ? '/financeiro/pre-fatura' : '/financeiro/novo',
      actions: const [AppBackButton(rotaAnterior: 'financeiro')],
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: _finalizando && _preFatura == null
              ? _buildSemPreFatura(carregando: financeiro.isLoading)
              : _buildFormulario(),
        ),
      ),
    );
  }

  /// Aberta pelo endereço antes do painel carregar, ou pré-fatura que já
  /// foi lançada.
  Widget _buildSemPreFatura({required bool carregando}) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: carregando
                ? const CircularProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Pré-fatura não encontrada. Ela pode já ter sido lançada.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageDescription,
                    ),
                  ),
          ),
        ),
        const AppBottomSpacer(folga: 0),
      ],
    );
  }

  Widget _buildFormulario() {
    final salvando =
        ref.watch(newInvoiceControllerProvider) is NewInvoiceSaving;
    final preFatura = _preFatura;

    final usuarios = ref.watch(usersControllerProvider).users;
    final pacientes = [
      for (final u in usuarios)
        if (u.role == UserRole.patient && u.active) u,
    ];
    final profissionais = preFatura != null
        ? {preFatura.professionalId: preFatura.professionalName}
        : {
            for (final u in usuarios)
              if (u.role == UserRole.professional && u.active) u.id: u.name,
          };

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              preFatura != null
                  ? 'CONFIRA OS DADOS DO ATENDIMENTO E FINALIZE A FATURA'
                  : 'PREENCHA OS DADOS PARA LANÇAR UMA NOVA FATURA',
              textAlign: TextAlign.center,
              style: AppTextStyles.pageDescription,
            ),
            const SizedBox(height: 16),

            // ---------- Paciente ----------
            if (preFatura != null)
              ProfileField(
                rotulo: 'PACIENTE',
                icon: Symbols.person,
                valorInicial: preFatura.patientName,
                habilitado: false,
              )
            else ...[
              const _Rotulo('PACIENTE'),
              PatientPicker(
                pacientes: pacientes,
                selecionado: _paciente,
                habilitado: !salvando,
                erro: _tentouSalvar && _paciente == null
                    ? 'Selecione um paciente'
                    : null,
                aoSelecionar: (p) => setState(() => _paciente = p),
                aoRemover: () => setState(() => _paciente = null),
              ),
              if (_paciente != null)
                PatientCreditsInfo(
                  patientId: _paciente!.id,
                  mensagem: (n) =>
                      'O paciente já tem ${PatientCreditsInfo.creditos(n)} '
                      'para usar.',
                ),
              const SizedBox(height: 16),
            ],

            // ---------- Profissional e tipo ----------
            AppSelectField<String>(
              rotulo: 'PROFISSIONAL',
              opcoes: profissionais.keys.toList(),
              rotuloOpcao: (id) => profissionais[id] ?? '',
              valor: preFatura?.professionalId ?? _profissionalId,
              habilitado:
                  preFatura == null && !salvando && profissionais.isNotEmpty,
              dica: profissionais.isEmpty
                  ? 'Carregando profissionais...'
                  : 'Selecione',
              aoMudar: (id) => setState(() => _profissionalId = id),
              validator: FormValidators.selecao,
            ),
            InvoiceTypeSelector(
              selecionado: _tipo,
              habilitado: !salvando,
              aoSelecionar: (tipo) => setState(() => _tipo = tipo),
            ),

            // ---------- Sessões ----------
            const _Rotulo('SESSÕES'),
            AppQuantityStepper(
              rotulo: 'Sessões',
              valor: _sessoes,
              minimo: _minimoSessoes,
              maximo: _maximoSessoes,
              habilitado: !salvando,
              aoMudar: _mudarSessoes,
            ),
            _AjudaSessoes(preFatura: preFatura, sessoes: _sessoes),
            const SizedBox(height: 12),

            // ---------- Valores ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProfileField(
                    rotulo: 'VALOR SESSÃO (R\$)',
                    controller: _valorController,
                    habilitado: !salvando,
                    teclado: TextInputType.number,
                    formatadores: [MoedaInputFormatter()],
                    dica: 'R\$',
                    validator: _validarValor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSelectField<PaymentMethod>(
                    rotulo: 'PAGAMENTO',
                    opcoes: PaymentMethod.values,
                    rotuloOpcao: (forma) => forma.label,
                    valor: _pagamento,
                    habilitado: !salvando,
                    aoMudar: (forma) => setState(() => _pagamento = forma),
                    validator: FormValidators.selecao,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProfileField(
                    rotulo: 'TOTAL',
                    controller: _totalController,
                    somenteLeitura: true,
                    dica: 'R\$',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileField(
                    rotulo: 'PERCENTUAL',
                    controller: _percentualController,
                    habilitado: !salvando,
                    teclado: TextInputType.number,
                    formatadores: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    dica: '%',
                    sufixo: '%',
                    validator: _validarPercentual,
                  ),
                ),
              ],
            ),
            ProfileField(
              rotulo: 'OBSERVAÇÕES',
              controller: _observacoesController,
              habilitado: !salvando,
              altura: 139,
              dica:
                  'Escreva aqui observações adicionais sobre o pagamento '
                  'ou pacote.',
            ),

            const SizedBox(height: 24),
            Center(
              child: AppSaveButton(
                label: preFatura != null ? 'Finalizar Fatura' : 'Lançar Fatura',
                largura: 220,
                carregando: salvando,
                onPressed: () => _salvar(profissionais),
              ),
            ),
            // Espaço para o menu inferior flutuante
            const AppBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

/// Rótulo de seção no mesmo estilo dos rótulos de campo.
class _Rotulo extends StatelessWidget {
  final String texto;

  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(texto, style: AppTextStyles.fieldLabel),
    );
  }
}

/// Explica o que acontece com as sessões faturadas.
class _AjudaSessoes extends StatelessWidget {
  final PreInvoiceModel? preFatura;
  final int sessoes;

  const _AjudaSessoes({required this.preFatura, required this.sessoes});

  @override
  Widget build(BuildContext context) {
    final preFatura = this.preFatura;
    final String texto;
    if (preFatura == null) {
      texto =
          'Sem atendimento agendado: as sessões viram créditos de '
          'agendamento do paciente.';
    } else {
      final agendadas =
          '${PreInvoiceCard.sessoes(preFatura.sessions)} '
          '${preFatura.sessions == 1 ? 'agendada' : 'agendadas'}';
      final extras = sessoes - preFatura.sessions;
      texto = extras == 0
          ? '$agendadas. Aumente para gerar créditos de agendamento.'
          : '$agendadas + ${PatientCreditsInfo.creditos(extras)}.';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
      ),
    );
  }
}
