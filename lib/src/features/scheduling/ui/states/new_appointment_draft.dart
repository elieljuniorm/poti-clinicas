import 'package:flutter/material.dart';

import '../../../../core/utils/datas.dart';
import '../../../users/domain/models/user_model.dart';
import '../../domain/models/new_appointment_model.dart';

/// Uma data escolhida no calendário, com os horários (ainda) preenchidos.
class SessionDraft {
  final DateTime date;
  final TimeOfDay? start;
  final TimeOfDay? end;

  const SessionDraft({required this.date, this.start, this.end});

  SessionDraft copyWith({TimeOfDay? start, TimeOfDay? end}) => SessionDraft(
    date: date,
    start: start ?? this.start,
    end: end ?? this.end,
  );

  static int _minutos(TimeOfDay hora) => hora.hour * 60 + hora.minute;

  bool get preenchida => start != null && end != null;

  /// Fim depois do início (só faz sentido com os dois preenchidos).
  bool get horarioValido => preenchida && _minutos(end!) > _minutos(start!);

  /// Mensagem para a linha da data, ou `null` se estiver tudo certo.
  /// [exigirPreenchimento]: só cobra os horários depois de tentar salvar.
  String? erro({required bool exigirPreenchimento}) {
    if (preenchida && !horarioValido) return 'O fim deve ser depois do início';
    if (exigirPreenchimento && !preenchida) return 'Preencha início e fim';
    return null;
  }

  AppointmentSessionModel toModel() => AppointmentSessionModel(
    start: DateTime(
      date.year,
      date.month,
      date.day,
      start!.hour,
      start!.minute,
    ),
    end: DateTime(date.year, date.month, date.day, end!.hour, end!.minute),
  );
}

/// Rascunho do novo agendamento: paciente, quantidade de sessões e as
/// datas com horários. Imutável: cada ação devolve um rascunho novo.
///
/// Regras:
/// - Não dá para marcar mais datas do que [sessionCount].
/// - Diminuir as sessões tira as datas mais distantes que sobrarem.
/// - Cada data tem início e fim próprios, escolhidos à mão: nada é
///   copiado de uma data para outra nem preenchido sozinho.
class NewAppointmentDraft {
  static const maximoSessoes = 30;

  final UserModel? patient;
  final int sessionCount;

  /// Em ordem de data.
  final List<SessionDraft> sessions;

  const NewAppointmentDraft({
    this.patient,
    this.sessionCount = 1,
    this.sessions = const [],
  });

  Set<DateTime> get datas => {for (final s in sessions) s.date};

  bool get datasCompletas => sessions.length == sessionCount;

  /// Quantas datas ainda faltam escolher.
  int get faltamDatas => sessionCount - sessions.length;

  bool get podeAdicionarData => sessions.length < sessionCount;

  bool get sessoesValidas =>
      datasCompletas && sessions.every((s) => s.horarioValido);

  NewAppointmentDraft _com({
    UserModel? patient,
    bool limparPaciente = false,
    int? sessionCount,
    List<SessionDraft>? sessions,
  }) {
    return NewAppointmentDraft(
      patient: limparPaciente ? null : patient ?? this.patient,
      sessionCount: sessionCount ?? this.sessionCount,
      sessions: sessions ?? this.sessions,
    );
  }

  // ---------- Paciente ----------

  NewAppointmentDraft selecionarPaciente(UserModel paciente) =>
      _com(patient: paciente);

  NewAppointmentDraft removerPaciente() => _com(limparPaciente: true);

  // ---------- Sessões e datas ----------

  NewAppointmentDraft definirQuantidade(int quantidade) {
    final total = quantidade.clamp(1, maximoSessoes);
    return _com(sessionCount: total, sessions: sessions.take(total).toList());
  }

  /// Marca a data se ela estiver livre e ainda couber; desmarca se já
  /// estiver marcada. Sem espaço, devolve o mesmo rascunho.
  NewAppointmentDraft alternarData(DateTime data) {
    final dia = Datas.dia(data);
    if (datas.contains(dia)) return removerData(dia);
    if (!podeAdicionarData) return this;

    final nova = SessionDraft(date: dia);
    return _com(
      sessions: [...sessions, nova]..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  NewAppointmentDraft removerData(DateTime data) {
    final dia = Datas.dia(data);
    return _com(sessions: sessions.where((s) => s.date != dia).toList());
  }

  // ---------- Horários ----------

  NewAppointmentDraft _alterar(
    DateTime data,
    SessionDraft Function(SessionDraft sessao) alterar,
  ) {
    final dia = Datas.dia(data);
    return _com(
      sessions: [for (final s in sessions) s.date == dia ? alterar(s) : s],
    );
  }

  /// Muda só o início desta data.
  NewAppointmentDraft definirInicio(DateTime data, TimeOfDay inicio) =>
      _alterar(data, (sessao) => sessao.copyWith(start: inicio));

  /// Muda só o fim desta data.
  NewAppointmentDraft definirFim(DateTime data, TimeOfDay fim) =>
      _alterar(data, (sessao) => sessao.copyWith(end: fim));

  /// Onde o seletor de fim abre quando o fim ainda está vazio: 1h depois
  /// do início (sem passar de 23:55). Só posiciona a rolagem; nada é
  /// gravado sem confirmar.
  static TimeOfDay sugestaoDeFim(TimeOfDay inicio) {
    final minutos = (inicio.hour * 60 + inicio.minute + 60).clamp(
      0,
      23 * 60 + 55,
    );
    return TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60);
  }

  // ---------- Envio ----------

  /// Model para enviar. Só chame com o rascunho válido.
  NewAppointmentModel toModel({
    required String professionalId,
    required String appointmentType,
    String? clinicalCase,
  }) {
    return NewAppointmentModel(
      patientId: patient!.id,
      professionalId: professionalId,
      appointmentType: appointmentType,
      clinicalCase: clinicalCase,
      sessions: [for (final s in sessions) s.toModel()],
    );
  }
}
