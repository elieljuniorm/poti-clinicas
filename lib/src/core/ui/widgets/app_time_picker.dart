import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_action_buttons.dart';

/// Abre uma folha inferior para escolher o horário (24h, de [intervalo]
/// em [intervalo] minutos). Devolve o horário confirmado ou `null` se a
/// folha for fechada.
///
/// Usa rolagem de hora e minuto, com textos em português (o seletor
/// padrão do Material sairia em inglês sem a tradução do Flutter).
Future<TimeOfDay?> showAppTimePicker(
  BuildContext context, {
  required String titulo,
  TimeOfDay? inicial,
  int intervalo = 5,
}) {
  final base = inicial ?? const TimeOfDay(hour: 8, minute: 0);
  // A rolagem só aceita minutos múltiplos do intervalo.
  final minuto = (base.minute ~/ intervalo) * intervalo;
  var escolhido = TimeOfDay(hour: base.hour, minute: minuto);

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: AppTextStyles.detailsSectionTitle),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                minuteInterval: intervalo,
                initialDateTime: DateTime(
                  2000,
                  1,
                  1,
                  escolhido.hour,
                  escolhido.minute,
                ),
                onDateTimeChanged: (data) =>
                    escolhido = TimeOfDay(hour: data.hour, minute: data.minute),
              ),
            ),
            const SizedBox(height: 8),
            AppSaveButton(
              label: 'Confirmar',
              onPressed: () => Navigator.of(contexto).pop(escolhido),
            ),
          ],
        ),
      ),
    ),
  );
}
