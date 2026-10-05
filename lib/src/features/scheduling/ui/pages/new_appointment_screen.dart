import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../core/ui/widgets/app_back_button.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../../../core/ui/widgets/app_multi_date_calendar.dart';
import '../../../../core/ui/widgets/app_quantity_stepper.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/widgets/app_select_field.dart';
import '../../../../core/ui/widgets/app_time_picker.dart';
import '../../../../core/utils/datas.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../profile/ui/widgets/profile_field.dart';
import '../../../users/application/users_controller.dart';
import '../../../users/domain/models/user_role.dart';
import '../../application/new_appointment_controller.dart';
import '../../domain/models/appointment_types.dart';
import '../states/new_appointment_draft.dart';
import '../states/new_appointment_state.dart';
import '../widgets/new_appointment/patient_picker.dart';
import '../widgets/new_appointment/session_tile.dart';

/// "Novo Atendimento": agenda sessões de um paciente já cadastrado com
/// um profissional. Aberta pelo card da Agenda.
///
/// Fluxo: paciente → quantidade de sessões → datas no calendário →
/// horários de cada data → profissional, tipo e caso clínico (opcional).
class NewAppointmentScreen extends ConsumerStatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  ConsumerState<NewAppointmentScreen> createState() =>
      _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends ConsumerState<NewAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _casoClinicoController = TextEditingController();

  NewAppointmentDraft _rascunho = const NewAppointmentDraft();
  String? _profissionalId;
  String? _tipo;

  /// Depois de tentar salvar, os campos vazios passam a mostrar erro.
  bool _tentouSalvar = false;

  /// Aviso abaixo do calendário (ex.: tentou marcar além das sessões).
  String? _avisoCalendario;

  @override
  void dispose() {
    _casoClinicoController.dispose();
    super.dispose();
  }

  void _atualizar(NewAppointmentDraft rascunho, {String? aviso}) {
    setState(() {
      _rascunho = rascunho;
      _avisoCalendario = aviso;
    });
  }

  void _alternarData(DateTime dia) {
    final marcada = _rascunho.datas.contains(dia);
    if (!marcada && !_rascunho.podeAdicionarData) {
      final total = _rascunho.sessionCount;
      _atualizar(
        _rascunho,
        aviso:
            'Você já escolheu ${total == 1 ? 'a sessão' : 'as $total sessões'}. '
            'Aumente as sessões ou remova uma data.',
      );
      return;
    }
    _atualizar(_rascunho.alternarData(dia));
  }

  Future<void> _escolherHorario(
    SessionDraft sessao, {
    required bool inicio,
  }) async {
    final rotulo = inicio ? 'Início' : 'Fim';
    final horario = await showAppTimePicker(
      context,
      titulo: '$rotulo — ${Datas.data(sessao.date)}',
      // Fim vazio: abre 1h depois do início (só a posição; nada é
      // gravado sem confirmar).
      inicial: inicio
          ? sessao.start
          : sessao.end ??
                (sessao.start == null
                    ? null
                    : NewAppointmentDraft.sugestaoDeFim(sessao.start!)),
    );
    if (horario == null || !mounted) return;

    _atualizar(
      inicio
          ? _rascunho.definirInicio(sessao.date, horario)
          : _rascunho.definirFim(sessao.date, horario),
    );
  }

  void _salvar(Map<String, String> profissionais) {
    setState(() => _tentouSalvar = true);
    final camposOk = _formKey.currentState!.validate();
    if (!camposOk || _rascunho.patient == null || !_rascunho.sessoesValidas) {
      return;
    }

    ref
        .read(newAppointmentControllerProvider.notifier)
        .agendar(
          _rascunho.toModel(
            professionalId: _profissionalId!,
            professionalName: profissionais[_profissionalId] ?? '',
            appointmentType: _tipo!,
            clinicalCase: _casoClinicoController.text,
          ),
        );
  }

  String? get _erroDatas {
    if (!_tentouSalvar || _rascunho.datasCompletas) return null;
    final faltam = _rascunho.faltamDatas;
    return faltam == 1
        ? 'Selecione mais 1 data'
        : 'Selecione mais $faltam datas';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NewAppointmentState>(newAppointmentControllerProvider, (
      previous,
      next,
    ) {
      // hideCurrentSnackBar: a mensagem nova substitui a anterior.
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (next is NewAppointmentSuccess) {
        final paciente = _rascunho.patient?.name ?? 'o paciente';
        final sessoes = next.sessions == 1
            ? '1 sessão agendada'
            : '${next.sessions} sessões agendadas';
        messenger.showSnackBar(
          SnackBar(content: Text('$sessoes para $paciente')),
        );
        context.goNamed('agenda');
      }
      if (next is NewAppointmentError) {
        messenger.showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final salvando =
        ref.watch(newAppointmentControllerProvider) is NewAppointmentSaving;
    final usuarios = ref.watch(usersControllerProvider).users;
    final pacientes = [
      for (final u in usuarios)
        if (u.role == UserRole.patient && u.active) u,
    ];
    final profissionais = {
      for (final u in usuarios)
        if (u.role == UserRole.professional && u.active) u.id: u.name,
    };

    return AppScaffold(
      titulo: 'Novo Atendimento',
      rotaAtual: '/agenda/novo',
      actions: const [AppBackButton(rotaAnterior: 'agenda')],
      backgroundColor: AppColors.background,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: AppColors.surfaceMuted,
          width: double.infinity,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PREENCHA OS DADOS PARA AGENDAR UM NOVO ATENDIMENTO',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageDescription,
                  ),
                  const SizedBox(height: 16),

                  // ---------- Paciente ----------
                  const _Rotulo('PACIENTE'),
                  PatientPicker(
                    pacientes: pacientes,
                    selecionado: _rascunho.patient,
                    habilitado: !salvando,
                    erro: _tentouSalvar && _rascunho.patient == null
                        ? 'Selecione um paciente'
                        : null,
                    aoSelecionar: (p) =>
                        _atualizar(_rascunho.selecionarPaciente(p)),
                    aoRemover: () => _atualizar(_rascunho.removerPaciente()),
                  ),
                  const SizedBox(height: 16),

                  // ---------- Sessões e calendário ----------
                  const _Rotulo('SESSÕES'),
                  AppQuantityStepper(
                    rotulo: 'Sessões',
                    valor: _rascunho.sessionCount,
                    maximo: NewAppointmentDraft.maximoSessoes,
                    habilitado: !salvando,
                    aoMudar: (n) => _atualizar(_rascunho.definirQuantidade(n)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'SELECIONE AS DATAS NO CALENDÁRIO ABAIXO',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionSubtitle,
                  ),
                  const SizedBox(height: 12),
                  AppMultiDateCalendar(
                    selecionadas: _rascunho.datas,
                    habilitado: !salvando,
                    aoAlternar: _alternarData,
                  ),
                  _ContadorDatas(
                    rascunho: _rascunho,
                    aviso: _avisoCalendario,
                    erro: _erroDatas,
                  ),

                  // ---------- Datas selecionadas ----------
                  if (_rascunho.sessions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _Rotulo('DATAS SELECIONADAS'),
                    for (final sessao in _rascunho.sessions)
                      SessionTile(
                        key: ValueKey(sessao.date),
                        sessao: sessao,
                        habilitado: !salvando,
                        erro: sessao.erro(exigirPreenchimento: _tentouSalvar),
                        aoEscolherInicio: () =>
                            _escolherHorario(sessao, inicio: true),
                        aoEscolherFim: () =>
                            _escolherHorario(sessao, inicio: false),
                        aoRemover: () =>
                            _atualizar(_rascunho.removerData(sessao.date)),
                      ),
                  ],
                  const SizedBox(height: 8),

                  // ---------- Profissional, tipo e caso clínico ----------
                  AppSelectField<String>(
                    rotulo: 'PROFISSIONAL',
                    opcoes: profissionais.keys.toList(),
                    rotuloOpcao: (id) => profissionais[id] ?? '',
                    valor: _profissionalId,
                    habilitado: !salvando && profissionais.isNotEmpty,
                    dica: profissionais.isEmpty
                        ? 'Carregando profissionais...'
                        : 'Selecione',
                    aoMudar: (id) => setState(() => _profissionalId = id),
                    validator: FormValidators.selecao,
                  ),
                  AppSelectField<String>(
                    rotulo: 'TIPO DE ATENDIMENTO',
                    opcoes: AppointmentTypes.todos,
                    rotuloOpcao: (tipo) => tipo,
                    valor: _tipo,
                    habilitado: !salvando,
                    aoMudar: (tipo) => setState(() => _tipo = tipo),
                    validator: FormValidators.selecao,
                  ),
                  ProfileField(
                    rotulo: 'CASO CLÍNICO',
                    controller: _casoClinicoController,
                    habilitado: !salvando,
                    altura: 139,
                    dica: 'Descreva o caso clínico (opcional)',
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: AppSaveButton(
                      carregando: salvando,
                      onPressed: () => _salvar(profissionais),
                    ),
                  ),
                  // Espaço para o menu inferior flutuante
                  const AppBottomSpacer(),
                ],
              ),
            ),
          ),
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

/// "2 de 4 datas selecionadas", ou o aviso/erro do calendário.
class _ContadorDatas extends StatelessWidget {
  final NewAppointmentDraft rascunho;
  final String? aviso;
  final String? erro;

  const _ContadorDatas({required this.rascunho, this.aviso, this.erro});

  @override
  Widget build(BuildContext context) {
    final total = rascunho.sessionCount;
    final escolhidas = rascunho.sessions.length;
    final mensagem =
        erro ??
        aviso ??
        '$escolhidas de $total ${total == 1 ? 'data selecionada' : 'datas selecionadas'}';
    final cor = erro != null
        ? AppColors.error
        : aviso != null
        ? AppColors.recordPending
        : AppColors.textHint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        mensagem,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: cor),
      ),
    );
  }
}
