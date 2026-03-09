import 'package:flutter/material.dart';
import 'package:signal_atlas/widgets/dropdown_menu.dart';

class DataFilters extends StatelessWidget {
  final List<String> operatorList;
  final String selectedOperator;
  final ValueChanged<String> onOperatorChanged;

  final bool showPredictedData;
  final ValueChanged<bool> onPredictionChanged;

  final List<String> periodList;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  final List<String> kpiList;
  final String selectedKPI;
  final ValueChanged<String> onKPIChanged;

  const DataFilters({
    super.key,
    required this.operatorList,
    required this.selectedOperator,
    required this.onOperatorChanged,
    required this.showPredictedData,
    required this.onPredictionChanged,
    required this.periodList,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.kpiList,
    required this.selectedKPI,
    required this.onKPIChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ------------------------------------------------
            // Operator Filter
            // ------------------------------------------------
            SizedBox(
              width: 65,
              child: Text(
                "Operator",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: CustomDropdown(
                items: operatorList,
                selectedItem: selectedOperator,
                onChanged: onOperatorChanged,
              ),
            ),
            const SizedBox(width: 8),
            // ------------------------------------------------
            // Prediction Switch
            // ------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Predictions",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: showPredictedData,
                  onChanged: onPredictionChanged,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // ------------------------------------------------
            // Period Filter
            // ------------------------------------------------
            SizedBox(
              width: 65,
              child: Text(
                "Period",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: CustomDropdown(
                items: periodList,
                selectedItem: selectedPeriod,
                onChanged: onPeriodChanged,
              ),
            ),
            const SizedBox(width: 8),
            // ------------------------------------------------
            // KPI Filter
            // ------------------------------------------------
            SizedBox(
              width: 32,
              child: Text(
                "KPI",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            CustomDropdown(
              items: kpiList,
              selectedItem: selectedKPI,
              onChanged: onKPIChanged,
            ),
          ],
        ),
      ],
    );
  }
}