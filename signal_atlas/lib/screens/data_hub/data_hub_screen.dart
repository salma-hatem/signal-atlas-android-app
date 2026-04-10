import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/logging_provider.dart';
import '../../widgets/page_wrapper.dart';

import 'package:signal_atlas/models/network_reading.dart';
import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/services/device_service.dart';

import 'widgets/sessions_table.dart';
import 'widgets/enable_logging_card.dart';
import 'widgets/server_health_card.dart';
import 'widgets/session_stat.dart';
import 'widgets/session_duration_text.dart';
import 'package:signal_atlas/widgets/custom_snackbar.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';

class DataHubPage extends StatefulWidget {
  const DataHubPage({
    super.key,
  });

  @override
  State<DataHubPage> createState() => _DataHubPageState();
}

class _DataHubPageState extends State<DataHubPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SessionProvider>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final sessionsProvider = context.watch<SessionProvider>();
    final loggingProvider = context.watch<LoggingProvider>();
    final isLoggingEnabled = loggingProvider.isLogging;

    return PageWrapper(
      title: "Data Hub",
      child: Column(
          children: <Widget>[
            // ------------------------------------------------
            // Controls (Health + Logging)
            // ------------------------------------------------
            IntrinsicHeight(
              child: Row(
                children: [
                  // ------------------------------------------------
                  // Logging
                  // ------------------------------------------------
                  Expanded(
                    flex: 2,
                    child: LoggingCard(),
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // Server Card
                  // ------------------------------------------------
                  Expanded(
                    flex: 1,
                    child: ServerCard(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // Current Session
            // ------------------------------------------------
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ClipRect(
                child: Align(
                  heightFactor: isLoggingEnabled ? 1.0 : 0.0,
                  child: Opacity(
                    opacity: isLoggingEnabled ? 1.0 : 0.0,
                    child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ------------------------------------------------
                                  // Header
                                  // ------------------------------------------------
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Current Session",
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // ------------------------------------------------
                                  // Content
                                  // ------------------------------------------------
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        SessionStat(
                                          tooltip: 'Session Duration',
                                          title: 'duration',
                                          value: '',
                                          textWidget: SessionDurationText(sessionsProvider),
                                          colorScheme: colorScheme,
                                        ),

                                        const SizedBox(width: 4),

                                        SessionStat(
                                            tooltip: 'Samples Collected',
                                            title: 'samples',
                                            value: sessionsProvider.liveSamples.toString(),
                                            colorScheme: colorScheme,
                                          ),

                                        const SizedBox(width: 4),

                                        SessionStat(
                                            tooltip: 'Device Speed',
                                            title: 'm/s',
                                            value: '',
                                            colorScheme: colorScheme
                                          ),

                                        const SizedBox(width: 4),

                                        SessionStat(
                                            tooltip: 'Samples sent each second',
                                            title: 'samples/s',
                                            value: '',
                                            colorScheme: colorScheme,
                                          ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ]
                    ),
                  ),
                ),
              ),
            ),

            // ------------------------------------------------
            // Device & Stats
            // ------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // Header
                    // ------------------------------------------------
                    Row(
                      children: [
                        Icon(Icons.memory, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Device Info",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error.withAlpha(180),
                            size: 20,
                          ),
                          tooltip: "Delete all data",
                          onPressed: () {
                            _showDeleteDialog(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // Content
                    // ------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Device ID"),
                        DeviceService.deviceId.value != null ?
                        Text(DeviceService.deviceId.value!)
                            : shimmerBox(context, height: 12, width: 150),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Samples"),
                        Text(sessionsProvider.totalSamples.toString()),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ------------------------------------------------
                        // Info icon
                        // ------------------------------------------------
                        Row(
                          children: [
                            Text("Total Samples on Server"),

                            const SizedBox(width: 6),

                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Data Retention"),
                                    content: const Text(
                                      "To keep data relevant and efficient, "
                                      "older or highly duplicated samples in the same area"
                                      " may be periodically removed from the server.",
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
                          ],
                        ),
                        sessionsProvider.totalSamplesServer != null
                            ? Text(sessionsProvider.totalSamplesServer.toString())
                            : shimmerBox(context, height: 12, width: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // Last Session
            // ------------------------------------------------
            LastSessionsCard(sessions: sessionsProvider.sessions)

          ]
      ),
    );
  }
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Data"),
        content: const Text(
          "Are you sure you want to delete all your data on the server? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await context.read<SessionProvider>().deleteAll();

              showCustomSnackBar(context, "All data deleted");
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
