import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/page_wrapper.dart';

import 'package:signal_atlas/models/sessions.dart';
import 'package:signal_atlas/providers/sessions_provider.dart';

import 'widgets/sessions_table.dart';
import 'widgets/enable_logging_card.dart';
import 'widgets/server_health_card.dart';
import 'package:signal_atlas/widgets/custom_snackbar.dart';

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
                        Text("123-ABC"),
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


final List<Session> lastSessions = [
  Session(date: DateTime(2026, 3, 18), duration: Duration(minutes: 12), sampleCount: 120),
  Session(date: DateTime(2026, 3, 17), duration: Duration(minutes: 25), sampleCount: 300),
  Session(date: DateTime(2026, 3, 16), duration: Duration(minutes: 18), sampleCount: 200),
  Session(date: DateTime(2026, 3, 15), duration: Duration(minutes: 20), sampleCount: 250),
  Session(date: DateTime(2026, 3, 14), duration: Duration(minutes: 15), sampleCount: 150),
  Session(date: DateTime(2026, 3, 13), duration: Duration(minutes: 10), sampleCount: 100),
];