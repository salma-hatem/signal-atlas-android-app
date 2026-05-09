import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/providers/logging_provider.dart';
import 'package:signal_atlas/services/platform_channel_service.dart';
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
      if (!context.read<LoggingProvider>().canLog) {
        showCustomSnackBar(context, "Server is offline");
        return;
      }

      if (!isLoggingEnabled) {
        final platform = context.read<PlatformChannelService>();
        final isIgnoring = await platform.isIgnoringBatteryOptimizations();
        if (!isIgnoring) {
          if (!context.mounted) return;
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Battery Optimization"),
              content: const Text(
                "Signal Atlas needs to run in the background to collect "
                "network data. Please disable battery optimization for this app.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );
          if (shouldOpen != true) return;
          await platform.requestBatteryOptimizationAndWait();
        }
      }

      if (!context.mounted) return;
      context.read<LoggingProvider>().toggleLogging();

      if (context.mounted) {
        showCustomSnackBar(
          context,
          isLoggingEnabled ? "Disabled logging" : "Enabled logging",
        );
      }
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => toggleLogging(),
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
