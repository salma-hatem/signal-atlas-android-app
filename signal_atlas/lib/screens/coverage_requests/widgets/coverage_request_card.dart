import 'package:flutter/material.dart';

import 'package:signal_atlas/models/coverage_request.dart';

import '../../../utilities/theme/app_colors.dart';

class CoverageRequestCard extends StatelessWidget {
  final CoverageRequest request;

  const CoverageRequestCard({
    super.key,
    required this.request,
  });

  Color _statusColor(
      String status,
      ColorScheme colorScheme,
      ) {
    switch (status) {
      case "Open":
        return AppColors.green;

      case "Cancelled":
        return colorScheme.error;

      case "Completed":
        return AppColors.orange;

      default:
        return colorScheme.outline;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Open":
        return Icons.access_time_rounded;

      case "Cancelled":
        return Icons.cancel_outlined;

      case "Completed":
        return Icons.check_circle_outline;

      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final statusColor = _statusColor(
      request.status,
      colorScheme,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // Header
            // ------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.outline,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              request.location,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 16,
                            color: AppColors.green,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "Reward",
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            request.rewardAmount.toStringAsFixed(0),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                              height: 1,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              "EGP",
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            // ------------------------------------------------
            // Footer
            // ------------------------------------------------

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(request.status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.outline,
                ),

                const SizedBox(width: 6),

                Text(
                  _formatDate(request.createdAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
