import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/providers/logging_provider.dart';
import 'package:signal_atlas/widgets/custom_snackbar.dart';

class LoggingCard extends StatelessWidget {
  const LoggingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loggingProvider = context.watch<LoggingProvider>();
    final isLoggingEnabled = loggingProvider.isLogging;
    final canLog = loggingProvider.canLog;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> toggleLogging() async {
      if (!canLog) {
        showCustomSnackBar(context, "Server is offline");
        return;
      }

      if (!isLoggingEnabled) {
        final isDisabled = await context.read<LoggingProvider>().isBatteryOptimizationDisabled();
        if (!isDisabled) {
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Battery Optimization"),
              content: const Text(
                "For reliable background data collection, please disable "
                "battery optimization for this app.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Continue anyway"),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<LoggingProvider>().requestBatteryOptimization();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            showCustomSnackBar(
              context,
              "Opened battery settings. Please disable optimization for this app.",
            );
          }
        }
      }

      context.read<LoggingProvider>().toggleLogging();

      showCustomSnackBar(
        context,
        isLoggingEnabled ? "Disabled logging" : "Enabled logging",
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: toggleLogging,
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
                    color: isLoggingEnabled
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
                          isLoggingEnabled ? "Enabled" : "Disabled",
                          style: TextStyle(
                            color: isLoggingEnabled
                                ? colorScheme.primary
                                : colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isLoggingEnabled,
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
