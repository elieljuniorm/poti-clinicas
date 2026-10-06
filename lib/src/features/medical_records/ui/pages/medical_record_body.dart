import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_bottom_spacer.dart';
import '../../domain/models/medical_record_details_model.dart';
import '../states/medical_record_state.dart';

/// Corpo comum das telas do prontuário de um paciente: fundo arredondado,
/// loading/erro do carregamento e o conteúdo com rolagem.
class MedicalRecordBody extends StatelessWidget {
  final MedicalRecordState state;
  final List<Widget> Function(MedicalRecordDetailsModel details) conteudo;

  const MedicalRecordBody({
    super.key,
    required this.state,
    required this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    final details = state.details;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: AppColors.surfaceMuted,
        width: double.infinity,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null || details == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Paciente não encontrado',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...conteudo(details),
                    // Espaço para o menu inferior flutuante
                    const AppBottomSpacer(),
                  ],
                ),
              ),
      ),
    );
  }
}
