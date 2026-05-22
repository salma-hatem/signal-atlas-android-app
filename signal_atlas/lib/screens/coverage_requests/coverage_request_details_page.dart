import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/screens/coverage_requests/widgets/coverage_request_map.dart';

import '../../models/coverage_request_detailed.dart';
import '../../providers/coverage_requests_provider.dart';
import '../../utilities/theme/app_colors.dart';
import '../../widgets/back_page_wrapper.dart';
import '../../widgets/shimmer_box.dart';

class CoverageRequestDetailsPage
    extends StatefulWidget {
  final int requestId;

  const CoverageRequestDetailsPage({
    super.key,
    required this.requestId,
  });

  @override
  State<CoverageRequestDetailsPage> createState() => _CoverageRequestDetailsPageState();
}

class _CoverageRequestDetailsPageState extends State<CoverageRequestDetailsPage> {
  CoverageRequestDetail? _request;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
    });

    final provider =
    context.read<CoverageRequestsProvider>();

    final request = await provider.fetchRequestDetails(
      widget.requestId,
    );

    if (!mounted) return;

    setState(() {
      _request = request;
      _isLoading = false;
    });

    await provider.loadUserContribution(
      widget.requestId,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoverageRequestsProvider>();

    final theme = Theme.of(context);

    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return BackPageWrapper(
      title: "Request Details",
      onRefresh: () async {
        await _loadRequest();
      },
      child: _isLoading || _request == null
          ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
              : _buildContent(
                  _request!,
                  provider,
                  textTheme,
                  colorScheme,
                )
    );
  }

  Widget _buildContent(
      CoverageRequestDetail request,
      CoverageRequestsProvider provider,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {

    final statusColor = _statusColor(
      request.status,
      colorScheme,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

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

        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              request.rewardAmount.toStringAsFixed(0),

              style:
              textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(width: 4),

            Padding(
              padding: const EdgeInsets.only(bottom: 4),

              child: Text(
                "EGP",

                style: textTheme.labelSmall?.copyWith(
                  color:
                  colorScheme.primary.withAlpha(180),

                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Text(
                request.status,

                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          request.description,

          style: textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 18),

        _buildMetaSection(request, textTheme, colorScheme),
        _buildProgressSection(request, textTheme, colorScheme),
        _buildContributionSection(provider, request, textTheme, colorScheme),

        const SizedBox(height: 24),

        SizedBox(
          height: 300,
          child: CoverageRequestMap(
            polygonPoints: request.area,
          ),
        ),

        const SizedBox(height: 18),

      ],
    );
  }

  Widget _buildMetaSection(
      CoverageRequestDetail request,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Created by (keep simple)
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              "Created by: ",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              request.createdBy,
              style: textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Timeline row
        Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 8),

            Text(
              _formatDate(request.createdAt),
              style: textTheme.bodyMedium,
            ),

            const SizedBox(width: 8),

            Icon(Icons.arrow_right_alt_rounded, color: colorScheme.outline),

            const SizedBox(width: 8),

            Text(
              request.completedAt != null
                  ? _formatDate(request.completedAt!)
                  : "--",
              style: textTheme.bodyMedium?.copyWith(
                color: request.completedAt != null
                    ? null
                    : colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(
      CoverageRequestDetail request,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    final progress = (request.currentDensityScore /
        request.targetDensityScore)
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        Text(
          "Coverage Progress",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _score("Initial", request.initialDensityScore, textTheme),
            _score("Current", request.currentDensityScore, textTheme),
            _score("Target", request.targetDensityScore, textTheme),
          ],
        ),
      ],
    );
  }

  Widget _score(String label, double value, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(0),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildContributionSection(
      CoverageRequestsProvider provider,
      CoverageRequestDetail request,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    final contribution = provider.userContribution;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        Text(
          "Your Contribution",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(20),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: colorScheme.primary.withAlpha(50),
            ),
          ),

          child: contribution == null
              ? Row(
                children: [
                  shimmerBox(context, height: 22, width: 120),

                  const SizedBox(width: 12),

                  shimmerBox(context, height: 18, width: 90),
                ],
              )

              : Row(
                children: [
                  Icon(
                    Icons.currency_exchange_rounded,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "${contribution.toStringAsFixed(1)} units",

                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 4,
                    height: 4,

                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "≈ ${request.userRewardShare(contribution).toStringAsFixed(2)} EGP",

                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
