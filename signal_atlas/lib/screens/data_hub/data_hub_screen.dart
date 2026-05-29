import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/logging_provider.dart';
import '../../utilities/constants.dart';
import '../../utilities/speed_format.dart';
import '../../widgets/page_wrapper.dart';

import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/services/device_service.dart';

import 'widgets/sessions_table.dart';
import 'widgets/enable_logging_card.dart';
import 'widgets/server_health_card.dart';
import '../../widgets/current_session_card.dart';
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
  UploadStatus _lastStatus = UploadStatus.idle;
  String? _lastMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SessionProvider>().loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<LoggingProvider>();

    final message = provider.statusMessage;

    final changed =
        provider.uploadStatus != _lastStatus ||
            message != _lastMessage;

    if (changed) {

      _lastStatus = provider.uploadStatus;
      _lastMessage = message;

      if (message != null) {

        WidgetsBinding.instance
            .addPostFrameCallback((_) {

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final sessionsProvider = context.watch<SessionProvider>();
    final loggingProvider = context.watch<LoggingProvider>();
    final isLoggingEnabled = loggingProvider.isLogging && loggingProvider.activeRequestId == null;

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
            CurrentSessionCard(
              isVisible: isLoggingEnabled,
              colorScheme: colorScheme,
              textTheme: textTheme,
              sessionsProvider: sessionsProvider,
              loggingProvider: loggingProvider,
              formatSpeed: formatSpeed,
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
          "Are you sure you want to delete all your data on the server? Coverage request sessions will be kept. This action cannot be undone.",
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

              showCustomSnackBar(context, "Data deleted");
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
