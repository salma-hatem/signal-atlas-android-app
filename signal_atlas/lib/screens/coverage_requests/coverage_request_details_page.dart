import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:signal_atlas/screens/coverage_requests/widgets/coverage_request_map.dart';

import '../../models/coverage_request_detailed.dart';
import '../../providers/coverage_requests_provider.dart';
import '../../providers/logging_provider.dart';
import '../../providers/sessions_provider.dart';
import '../../services/coverage_area_tracking_service.dart';
import '../../services/network_readings_service.dart';
import '../../utilities/speed_format.dart';
import '../../utilities/theme/app_colors.dart';
import '../../widgets/back_page_wrapper.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/shimmer_box.dart';
import '../../widgets/current_session_card.dart';

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
  bool isInsideArea = false;
  bool _wasInside = true;

  late final CoverageAreaTrackingService _trackingService;
  StreamSubscription<bool>? _insideSub;
  bool _trackingInitialized = false;

  @override
  void initState() {
    super.initState();

    _loadRequest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_trackingInitialized) return;
    _trackingInitialized = true;

    final readingsService = context.read<NetworkReadingsService>();

    _trackingService = CoverageAreaTrackingService(
      readingStream: readingsService.readingStream,
    );

    _loadRequest();
  }

  @override
  void dispose() {
    _insideSub?.cancel();
    _trackingService.dispose();

    super.dispose();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
    });

    final provider =
    context.read<CoverageRequestsProvider>();

    final request = await provider.fetchRequestDetails(widget.requestId);

    if (!mounted) return;

    _trackingService.startTracking(request.area);

    await _insideSub?.cancel();

    _insideSub = _trackingService.insideStream.listen((inside) async {
      if (!mounted) return;

      final loggingProvider = context.read<LoggingProvider>();

      final wasInside = _wasInside;
      _wasInside = inside;

      setState(() {
        isInsideArea = inside;
      });

      // ONLY trigger when: logging is ON + transitioned INSIDE -> OUTSIDE
      final shouldVibrate =
          loggingProvider.isLogging &&
              wasInside == true &&
              inside == false;

      if (shouldVibrate) {
        final canVibrate = await Vibration.hasVibrator() ?? false;

        if (canVibrate) {
          Vibration.vibrate(
            duration: 500,
            amplitude: 128,
          );
        }
      }
    });

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
      case "OPEN":
        return AppColors.green;

      case "CANCELLED":
        return colorScheme.error;

      case "COMPLETED":
        return AppColors.orange;

      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoverageRequestsProvider>();
    final loggingProvider = context.watch<LoggingProvider>();
    final sessionsProvider = context.watch<SessionProvider>();
    final isStopping = loggingProvider.isStopping;

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
            loggingProvider,
            sessionsProvider,
            textTheme,
            colorScheme,
            isStopping,
          ),
        );
  }

  Widget _buildContent(
      CoverageRequestDetail request,
      CoverageRequestsProvider provider,
      LoggingProvider loggingProvider,
      SessionProvider sessionsProvider,
      TextTheme textTheme,
      ColorScheme colorScheme,
      bool isStopping,
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

        _buildMetaSection(
          request,
          loggingProvider,
          sessionsProvider,
          provider,
          textTheme,
          colorScheme,
          isStopping,
        ),
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
      LoggingProvider loggingProvider,
      SessionProvider sessionsProvider,
      CoverageRequestsProvider requestsProvider,
      TextTheme textTheme,
      ColorScheme colorScheme,
      bool isStopping,
      ){

    final isRequestOpen = request.status == "OPEN";

    final isThisRequestActive =
        requestsProvider.activeRequestId == request.id;

    final anotherSessionActive =
        loggingProvider.isLogging &&
            !isThisRequestActive;

    final canEnableLogging =
        isRequestOpen &&
            isInsideArea &&
            (!loggingProvider.isLogging || isThisRequestActive);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // CREATED BY
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

                      Expanded(
                        child: Text(
                          request.createdBy,
                          style: textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TIMELINE
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

                      Icon(
                        Icons.arrow_right_alt_rounded,
                        color: colorScheme.outline,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        request.completedAt != null
                            ? _formatDate(
                            request.completedAt!)
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
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(
                        isInsideArea
                            ? Icons.check_circle_outline
                            : Icons.location_off_outlined,

                        size: 18,

                        color: isInsideArea
                            ? AppColors.green
                            : colorScheme.error,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        isInsideArea
                            ? "Inside coverage area"
                            : "Outside coverage area",

                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,

                          color: isInsideArea
                              ? AppColors.green
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isInsideArea
                        ? "You can contribute data to this request."
                        : "Move into the highlighted area to enable logging.",

                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Opacity(
              opacity: ((canEnableLogging || isThisRequestActive) &&
                  isRequestOpen &&
                  !isStopping)
                  ? 1
                  : 0.5,

              child: Material(
                borderRadius: BorderRadius.circular(14),

                child: InkWell(
                  borderRadius: BorderRadius.circular(14),

                  onTap: (!isRequestOpen || isStopping)
                      ? null
                      : () async {
                    if (anotherSessionActive) {
                      showCustomSnackBar(
                        context,
                        "Another logging session is already active",
                      );
                      return;
                    }

                    if (!isInsideArea && !isThisRequestActive) {
                      showCustomSnackBar(
                        context,
                        "You must be inside the coverage area",
                      );
                      return;
                    }

                    try {
                      await requestsProvider.toggleRequestLogging(
                        requestId: request.id,
                        requestTitle: request.title,
                        loggingProvider: loggingProvider,
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          isStopping = false;
                        });
                      }
                    }
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: isThisRequestActive
                          ? AppColors.primary.withAlpha(30)
                          : colorScheme.surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(
                        color: isThisRequestActive
                            ? AppColors.primary.withAlpha(120)
                            : colorScheme.outline.withAlpha(40),
                      ),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        isStopping
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  :  Icon(
                            isThisRequestActive
                                ? Icons.radio_button_on_rounded
                                : Icons.play_arrow_rounded,

                            size: 18,

                            color: isThisRequestActive
                                ? AppColors.primary
                                : colorScheme.onSurfaceVariant,
                          ),

                        const SizedBox(width: 8),

                        Text(
                          isThisRequestActive
                              ? "Logging Enabled"
                              : "Enable Logging",

                          style: textTheme.labelLarge?.copyWith(
                            color: isThisRequestActive
                                ? AppColors.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
          ],
        ),

        const SizedBox(height: 18),

        CurrentSessionCard(
          isVisible: isThisRequestActive,

          colorScheme: colorScheme,
          textTheme: textTheme,

          sessionsProvider: sessionsProvider,
          loggingProvider: loggingProvider,

          formatSpeed: formatSpeed,
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
