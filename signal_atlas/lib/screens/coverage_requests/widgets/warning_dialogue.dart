import 'package:flutter/material.dart';
import '../../../providers/logging_provider.dart';

Future<bool> showCoverageWarningDialog(
    BuildContext context,
    LoggingProvider loggingProvider,
    ) async {
  bool doNotShowAgain = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Start Data Collection?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Collected coverage data cannot be deleted after submission.",
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: doNotShowAgain,
                      onChanged: (val) {
                        setState(() {
                          doNotShowAgain = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text("Do not show again"),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Continue"),
              ),
            ],
          );
        },
      );
    },
  );

  if (result == true && doNotShowAgain) {
    await loggingProvider.setSkipCoverageWarning(true);
  }

  return result ?? false;
}
