import 'package:flutter/material.dart';

import '../../domain/models/financial_summary_model.dart';
import 'financial_entry_card.dart';

class FinancialSummaryWidget extends StatelessWidget {
  final List<FinancialSummaryModel> summaries;

  const FinancialSummaryWidget({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) =>
          FinancialEntryCard(item: summaries[index]),
    );
  }
}
