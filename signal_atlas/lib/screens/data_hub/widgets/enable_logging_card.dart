import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/providers/logging_provider.dart';
import 'package:signal_atlas/widgets/custom_snackbar.dart';

class LoggingCard extends StatelessWidget {
  const LoggingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loggingProvider = context.watch<LoggingProvider>();

    final isGeneralLoggingEnabled =
        loggingProvider.isLogging &&
            loggingProvider.activeRequestId == null;

    final canLog = loggingProvider.canLog;

    final anotherRequestActive = loggingProvider.isLogging && loggingProvider.activeRequestId != null;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void toggleLogging() {
      if (!canLog) {
        showCustomSnackBar(context, "Server is offline");
        return;
      }

      context.read<LoggingProvider>().toggleLogging();

      showCustomSnackBar(
        context,
        isGeneralLoggingEnabled ? "Disabled logging" : "Enabled logging",
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (anotherRequestActive) {
              showCustomSnackBar(
                context,
                "A request logging session is already active",
              );
              return;
            }

            loggingProvider.toggleLogging();
          },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // Status + Switch
              // ------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.data_usage,
                    color: isGeneralLoggingEnabled
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Logging",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGeneralLoggingEnabled ? "Enabled" : "Disabled",
                          style: TextStyle(
                            color: isGeneralLoggingEnabled
                                ? colorScheme.primary
                                : colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isGeneralLoggingEnabled,
                    onChanged: canLog ? (_) => toggleLogging() : null,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // Info + Description
              // ------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Data Logging"),
                          content: const Text(
                            "When enabled, your device will upload collected network "
                                "measurements to help improve coverage maps and insights. "
                                "No personal data is shared.",
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Share data to improve coverage insights",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
