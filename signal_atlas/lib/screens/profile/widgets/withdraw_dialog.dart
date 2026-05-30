import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../providers/profile_provider.dart';
import '../../../widgets/filter_chip.dart';

class WithdrawDialog extends StatefulWidget {
  final double availableCredits;

  const WithdrawDialog({
    super.key,
    required this.availableCredits,
  });

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  static const double minAmount = 10;

  late double maxAmount;
  double rawAmount = 0; // what user types (authoritative for text)
  int stepAmount = 0;   // what slider uses (snapped)
  int sliderIndex = 0;
  late List<int> steps;
  String? selectedPreset;

  late FocusNode focusNode;
  Timer? _debounce;
  String draftText = "";

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    maxAmount = widget.availableCredits.clamp(minAmount, 1000);

    // generate 10 equal integer steps
    steps = List.generate(
      11,
          (i) => (minAmount + ((maxAmount - minAmount) * i / 10)).floor(),
    );

    rawAmount = minAmount;
    stepAmount = minAmount.toInt();
    sliderIndex = 0;

    draftText = rawAmount.toString();

    controller = TextEditingController(text: draftText);

    focusNode = FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _commitDraft(); // commit when user leaves field
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      ("25%", "25", 0.25),
      ("50%", "50", 0.50),
      ("75%", "75", 0.75),
      ("Max", "max", 1.0),
    ];

    return AlertDialog(
      title: const Text("Withdraw Credits"),

      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Available: ${widget.availableCredits.toStringAsFixed(2)}",
            ),

            const SizedBox(height: 16),

            TextField(
              focusNode: focusNode,
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Amount"),
              onChanged: (value) {
                setState(() {
                  draftText = value;
                });

                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 600),
                  _commitDraft,
                );
              },
            ),

            const SizedBox(height: 16),

            Slider(
              value: sliderIndex.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: stepAmount.toString(),
              onChanged: (value) {
                final index = value.round();

                setState(() {
                  sliderIndex = index;
                  stepAmount = steps[index];

                  rawAmount = stepAmount.toDouble(); // slider overrides text

                  controller.text = stepAmount.toString();
                  selectedPreset = _detectPreset(rawAmount);
                });
              },
            ),

            Text(
              "Minimum: ${minAmount.floor().toString()}",
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall,
            ),

            Wrap(
              spacing: 4,
              children: presets.map((p) {
                return StyledFilterChip(
                  label: p.$1,
                  selected: selectedPreset == p.$2,
                  showCheckmark: false,
                  onSelected: (selected) {
                    setAmount(maxAmount * p.$3, preset: p.$2);
                  },
                );
              }).toList(),
            )

          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: () {
            context.read<ProfileProvider>().withdraw(rawAmount);
            Navigator.pop(context);
          },
          child: const Text("Withdraw"),
        ),
      ],
    );
  }

  void setAmount(double value, {String? preset}) {
    final clamped = value.clamp(minAmount, maxAmount).toDouble();

    setState(() {
      rawAmount = clamped;

      controller.text = clamped.toStringAsFixed(2);

      _syncSliderToNearestStep(clamped);
      selectedPreset = preset ?? _detectPreset(clamped);
    });
  }

  String? _detectPreset(double value) {
    final tolerance = maxAmount * 0.02;

    if ((value - maxAmount * 0.25).abs() <= tolerance) return "25";
    if ((value - maxAmount * 0.50).abs() <= tolerance) return "50";
    if ((value - maxAmount * 0.75).abs() <= tolerance) return "75";
    if ((value - maxAmount).abs() <= tolerance) return "max";

    return null;
  }

  void _commitDraft() {
    final parsed = double.tryParse(draftText);
    if (parsed == null) return;

    final clamped = parsed.clamp(minAmount, maxAmount).toDouble();

    setState(() {
      rawAmount = clamped;

      controller.text = clamped.toStringAsFixed(2);

      _syncSliderToNearestStep(clamped);
      selectedPreset = _detectPreset(clamped);
    });
  }

  void _syncSliderToNearestStep(double value) {
    int closestIndex = 0;
    double bestDiff = double.infinity;

    for (int i = 0; i < steps.length; i++) {
      final diff = (steps[i] - value).abs();

      if (diff < bestDiff) {
        bestDiff = diff;
        closestIndex = i;
      }
    }

    sliderIndex = closestIndex;
    stepAmount = steps[closestIndex];
  }

}
