import 'package:flutter/material.dart';
import 'package:signal_atlas/models/sessions.dart';
import 'package:signal_atlas/widgets/table.dart';
import '../all_sessions_screen.dart';

class LastSessionsCard extends StatelessWidget {
  final List<Session> sessions;
  const LastSessionsCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // Card Title
            // ------------------------------------------------
            Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                    "Last Sessions",
                    style: textTheme.titleMedium
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ------------------------------------------------
            // Session Table
            // ------------------------------------------------
            SessionsTable(
              sessions: sessions,
              scrollable: false,
              maxRows: 5,
              columns: [
                SessionColumn(
                  title: "Date",
                  valueBuilder: (s) => s.dateString,
                ),
                SessionColumn(
                  title: "Duration",
                  valueBuilder: (s) => s.durationString,
                ),
                SessionColumn(
                  title: "Samples",
                  valueBuilder: (s) => s.sampleCount.toString(),
                  align: TextAlign.right,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ------------------------------------------------
            // View more button
            // ------------------------------------------------
            if (sessions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllSessionsPage(sessions: sessions),
                      ),
                    );
                  },
                  child: const Text("View More"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
