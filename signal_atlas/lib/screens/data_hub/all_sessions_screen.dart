import 'package:flutter/material.dart';
import 'package:signal_atlas/models/sessions.dart';
import 'package:signal_atlas/widgets/table.dart';
import '../../utilities/theme/app_colors.dart';
import '../../widgets/back_page_wrapper.dart';
import '../../widgets/custom_overlay_tooltip.dart';

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
              title: "",
              flex: 0,
              padding: const EdgeInsets.all(2),
              widgetBuilder: (s) {
                if (!s.isCoverageRequest) {
                  return const SizedBox(
                    width: 28,
                    height: 28,
                  );
                }

                return CustomOverlayTooltip(
                  tooltip:
                  s.requestTitle ?? "Coverage Request Session",
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.green.withAlpha(80),
                      ),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      size: 16,
                      color: AppColors.green,
                    ),
                  ),
                );
              },
            ),
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
            ),
          ],
        )
    );
  }
}
