import 'package:flutter/material.dart';
import 'package:signal_atlas/models/sessions.dart';
import 'package:signal_atlas/widgets/table.dart';
import '../../widgets/back_page_wrapper.dart';

class AllSessionsPage extends StatelessWidget {
  final List<Session> sessions;

  const AllSessionsPage({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return BackPageWrapper(
      title: "All Sessions",
      scrollable: false,
      child: SessionsTable(
          sessions: sessions,
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
            ),
            SessionColumn(
              title: "Avg Rate",
              valueBuilder: (s) {
                return "${ s.avgRatePerMin.toStringAsFixed(1)} / min";
              },
              align: TextAlign.right,
            ),
          ],
        )
    );
  }
}
