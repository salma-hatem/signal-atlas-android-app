import 'package:flutter/material.dart';
import '../providers/logging_provider.dart';
import '../providers/sessions_provider.dart';
import '../screens/data_hub/widgets/upload_status_indicator.dart';
import '../screens/data_hub/widgets/session_stat.dart';
import '../screens/data_hub/widgets/session_duration_text.dart';

class CurrentSessionCard extends StatelessWidget {
  final bool isVisible;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final SessionProvider sessionsProvider;
  final LoggingProvider loggingProvider;
  final String Function(double) formatSpeed;

  const CurrentSessionCard({
    super.key,
    required this.isVisible,
    required this.colorScheme,
    required this.textTheme,
    required this.sessionsProvider,
    required this.loggingProvider,
    required this.formatSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ClipRect(
        child: Align(
          heightFactor: isVisible ? 1.0 : 0,
          child: Opacity(
            opacity: isVisible ? 1.0 : 0,
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
                            Icon(Icons.timer_outlined,
                                color: colorScheme.primary),
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
                        // Stats
                        // ------------------------------------------------
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              SessionStat(
                                tooltip: 'Session Duration',
                                title: 'duration',
                                value: '',
                                textWidget:
                                SessionDurationText(sessionsProvider),
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
                                value: formatSpeed(
                                    loggingProvider.currentSpeedMps),
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(width: 4),

                              SessionStat(
                                tooltip: 'Samples sent each minute',
                                title: 'samples/min',
                                value: loggingProvider
                                    .currentSendingRatePerMinute
                                    .toStringAsFixed(1),
                                colorScheme: colorScheme,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // Upload status
                        // ------------------------------------------------
                        Text(
                          "Upload Status",
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        UploadStatusIndicator(
                          status: loggingProvider.uploadStatus,
                          message: loggingProvider.statusMessage,
                        ),

                        if (loggingProvider.samplesFailedCount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Failed Samples"),
                              Text("${loggingProvider.samplesFailedCount}"),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
