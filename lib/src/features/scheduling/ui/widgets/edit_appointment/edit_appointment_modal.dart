import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/ui/theme/app_colors.dart';
import '../../../../../core/ui/theme/app_decorations.dart';
import '../../../../../core/ui/theme/app_text_styles.dart';
import '../../../../../core/ui/widgets/app_action_buttons.dart';
import '../../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../../core/ui/widgets/app_multi_date_calendar.dart';
import '../../../../../core/ui/widgets/app_select_field.dart';
import '../../../../../core/ui/widgets/app_time_picker.dart';
import '../../../../../core/utils/datas.dart';
import '../../../../../core/utils/documento.dart';
import '../../../../../core/utils/form_validators.dart';
import '../../../../profile/ui/widgets/profile_field.dart';
import '../../../../users/application/users_controller.dart';
import '../../../../users/domain/models/user_model.dart';
import '../../../../users/domain/models/user_role.dart';
import '../../../application/edit_appointment_controller.dart';
import '../../../domain/models/appointment_types.dart';
import '../../../domain/models/scheduling_appointment_model.dart';
import '../../states/edit_appointment_draft.dart';
import '../../states/edit_appointment_state.dart';
import '../new_appointment/session_tile.dart';
import 'appointment_status_selector.dart';

/// Abre o modal "Editar agendamento" de um atendimento da Agenda
/// (padrão de [showAppModalSheet]). Fechar sem salvar descarta tudo.
Future<void> showEditAppointmentModal(
  BuildContext context,
  SchedulingAppointmentModel atendimento,
) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => EditAppointmentModal(atendimento: atendimento),
  );
}

/// Edita um atendimento: status, data, horário, profissional, tipo e caso
/// clínico. "Salvar alterações" grava; "Descartar alterações" (ou arrastar
/// para baixo) fecha e o atendimento continua como estava.
class EditAppointmentModal extends ConsumerStatefulWidget {
  final SchedulingAppointmentModel atendimento;

  const EditAppointmentModal({super.key, required this.atendimento});

  @override
  ConsumerState<EditAppointmentModal> createState() =>
      _EditAppointmentModalState();
}

class _EditAppointmentModalState extends ConsumerState<EditAppointmentModal> {
  final _formKey = GlobalKey<FormState>();
  late EditAppointmentDraft _rascunho = EditAppointmentDraft.de(
    widget.atendimento,
  );
  late final _casoClinicoController = TextEditingController(
    text: widget.atendimento.clinicalCase,
  );
  bool _tentouSalvar = false;

  @override
  void dispose() {
    _casoClinicoController.dispose();
    super.dispose();
  }

  void _atualizar(EditAppointmentDraft rascunho) {
    setState(() => _rascunho = rascunho);
  }

  Future<void> _escolherHorario({required bool inicio}) async {
    final sessao = _rascunho.sessao;
    final horario = await showAppTimePicker(
      context,
      titulo: '${inicio ? 'Início' : 'Fim'} — ${Datas.data(sessao.date)}',
      inicial: inicio ? sessao.start : sessao.end,
    );
    if (horario == null || !mounted) return;
    _atualizar(
      inicio ? _rascunho.definirInicio(horario) : _rascunho.definirFim(horario),
    );
  }

  void _salvar(Map<String, String> profissionais) {
    setState(() => _tentouSalvar = true);
    if (!_formKey.currentState!.validate() || !_rascunho.valido) return;

    ref
        .read(editAppointmentControllerProvider.notifier)
        .salvar(
          _rascunho.aplicar(
            professionalName:
                profissionais[_rascunho.professionalId] ??
                widget.atendimento.professional,
            clinicalCase: _casoClinicoController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EditAppointmentState>(editAppointmentControllerProvider, (
      previous,
      next,
    ) {
      if (next is EditAppointmentSuccess) {
        // O aviso aparece na Agenda, depois que o modal fecha.
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Agendamento de ${next.appointment.patient} atualizado',
            ),
          ),
        );
      }
    });

    final estado = ref.watch(editAppointmentControllerProvider);
    final salvando = estado is EditAppointmentSaving;
    final atendimento = widget.atendimento;

    final usuarios = ref.watch(usersControllerProvider).users;
    final paciente = usuarios
        .where((u) => u.id == atendimento.patientId)
        .firstOrNull;
    // Profissionais ativos; o atual entra mesmo se não estiver na lista.
    final profissionais = {
      for (final u in usuarios)
        if (u.role == UserRole.professional && u.active) u.id: u.name,
    }..putIfAbsent(atendimento.professionalId, () => atendimento.professional);
    final tipos = {...AppointmentTypes.todos, atendimento.appointmentType};

    final hoje = Datas.dia(DateTime.now());
    final sessao = _rascunho.sessao;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Área fixa (não rola): arrastar aqui fecha o modal.
        const AppSheetHandle(),
        Flexible(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PREENCHA OS DADOS PARA EDITAR OU DESMARCAR ATENDIMENTO',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageDescription,
                  ),
                  const SizedBox(height: 16),

                  // ---------- Paciente (fixo) ----------
                  const _Rotulo('PACIENTE'),
                  _CardPaciente(nome: atendimento.patient, paciente: paciente),
                  const SizedBox(height: 12),

                  // ---------- Status ----------
                  AppointmentStatusSelector(
                    selecionado: _rascunho.status,
                    habilitado: !salvando,
                    aoSelecionar: (s) => _atualizar(_rascunho.alterarStatus(s)),
                  ),
                  const SizedBox(height: 12),

                  // ---------- Data (uma só) ----------
                  AppMultiDateCalendar(
                    selecionadas: {sessao.date},
                    mesInicial: sessao.date,
                    // Um atendimento já passado continua visível; a nova
                    // data só pode ser de hoje em diante.
                    primeiroDia: hoje,
                    habilitado: !salvando,
                    aoAlternar: (dia) => _atualizar(_rascunho.alterarData(dia)),
                  ),
                  const SizedBox(height: 16),
                  const _Rotulo('DATA SELECIONADA'),
                  SessionTile(
                    sessao: sessao,
                    habilitado: !salvando,
                    erro: sessao.erro(exigirPreenchimento: _tentouSalvar),
                    aoEscolherInicio: () => _escolherHorario(inicio: true),
                    aoEscolherFim: () => _escolherHorario(inicio: false),
                  ),
                  const SizedBox(height: 8),

                  // ---------- Profissional, tipo e caso clínico ----------
                  AppSelectField<String>(
                    rotulo: 'PROFISSIONAL',
                    opcoes: profissionais.keys.toList(),
                    rotuloOpcao: (id) => profissionais[id] ?? '',
                    valor: _rascunho.professionalId,
                    habilitado: !salvando,
                    aoMudar: (id) {
                      if (id != null) {
                        _atualizar(_rascunho.alterarProfissional(id));
                      }
                    },
                    validator: FormValidators.selecao,
                  ),
                  AppSelectField<String>(
                    rotulo: 'TIPO DE ATENDIMENTO',
                    opcoes: tipos.toList(),
                    rotuloOpcao: (tipo) => tipo,
                    valor: _rascunho.appointmentType,
                    habilitado: !salvando,
                    aoMudar: (tipo) {
                      if (tipo != null) _atualizar(_rascunho.alterarTipo(tipo));
                    },
                    validator: FormValidators.selecao,
                  ),
                  ProfileField(
                    rotulo: 'CASO CLÍNICO',
                    controller: _casoClinicoController,
                    habilitado: !salvando,
                    altura: 139,
                    dica: 'Descreva o caso clínico (opcional)',
                  ),

                  if (estado is EditAppointmentError) ...[
                    const SizedBox(height: 8),
                    Text(
                      estado.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: AppSaveButton(
                      label: 'Salvar alterações',
                      largura: 290,
                      carregando: salvando,
                      onPressed: () => _salvar(profissionais),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: salvando
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text(
                        'Descartar alterações',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

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

/// Paciente do atendimento: nome, CPF e categoria (Pediatria, Adulto,
/// Idoso), vindos do cadastro de usuários.
class _CardPaciente extends StatelessWidget {
  final String nome;

  /// Cadastro do paciente; `null` enquanto a lista carrega.
  final UserModel? paciente;

  const _CardPaciente({required this.nome, required this.paciente});

  @override
  Widget build(BuildContext context) {
    final documento = paciente?.document;
    final categoria = paciente?.patientCategory?.label;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (documento != null && documento.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'CPF: ${Documento.mascararCpf(documento)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (categoria != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.actionCardBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoria,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.borderAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
