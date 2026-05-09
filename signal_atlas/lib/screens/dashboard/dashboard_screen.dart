import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/page_wrapper.dart';

import 'package:signal_atlas/providers/network_reading_provider.dart';
import 'package:signal_atlas/providers/dashboard_provider.dart';
import '/utilities/theme/app_colors.dart';
import '/utilities/timestamp_format.dart';

import 'package:signal_atlas/widgets/line_chart.dart';
import 'widgets/data_filters_widgets.dart';
import 'widgets/coverage_map.dart';
import 'widgets/stats_card.dart';
import 'widgets/heatmap_legend.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _mapEnabled = false;
  bool _initialized = false;
  bool _listenerRegistered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final provider = Provider.of<CurrentNetworkReadingProvider>(context, listen: false);
      final reading = provider.latestReading;
      if (reading != null) {
        final dashboard = context.read<DashboardProvider>();
        dashboard.setReading(reading);
        dashboard.initializeDashboard();
        _initialized = true;
      } else if (!_listenerRegistered) {
        _listenerRegistered = true;
        provider.addListener(_onReadingUpdated);
      }
    }
  }

  void _onReadingUpdated() {
    final provider = Provider.of<CurrentNetworkReadingProvider>(context, listen: false);
    final reading = provider.latestReading;
    if (reading != null) {
      final dashboard = context.read<DashboardProvider>();
      dashboard.setReading(reading);
      dashboard.initializeDashboard();
      provider.removeListener(_onReadingUpdated);
      _initialized = true;
      _listenerRegistered = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final dashboard = context.watch<DashboardProvider>();
    final xData = dashboard.trendPoints.map((p) => p.timeMs).toList();
    final rsrpPoints = dashboard.trendPoints.map((p) => p.rsrp).toList();
    final rsrqPoints = dashboard.trendPoints.map((p) => p.rsrq).toList();

    return PageWrapper(
        title: "Dashboard",
        onRefresh: () async {
          final reading = context.read<CurrentNetworkReadingProvider>().latestReading;

          if (reading != null) {
            await context.read<DashboardProvider>().loadDashboard(reading);
            print('long ${reading.longitude}');
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_mapEnabled) setState(() => _mapEnabled = false);
          },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // Filters
                // ------------------------------------------------
                DataFilters(
                  operatorList: dashboard.operatorList,
                  selectedOperator: dashboard.selectedOperator,
                  onOperatorChanged: dashboard.updateOperator,

                  showPredictedData: dashboard.showPredictedData,
                  onPredictionChanged: dashboard.updatePrediction,

                  periodList: dashboard.periodList,
                  selectedPeriod: dashboard.selectedPeriod,
                  onPeriodChanged: dashboard.updatePeriod,

                  kpiList: dashboard.kpiList,
                  selectedKPI: dashboard.selectedKPI,
                  onKPIChanged: dashboard.updateKPI,
                ),
                SizedBox(height: 12),
                // ------------------------------------------------
                // Overview Card
                // ------------------------------------------------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ------------------------------------------------
                        // Card Title
                        // ------------------------------------------------
                        Row(
                          children: [
                            Icon(
                              Icons.dashboard_outlined,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Overview",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ------------------------------------------------
                        // Stats Cards
                        // ------------------------------------------------
                        Column(
                          children: [
                            // First row
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: StatsCard(
                                        title: "Mean RSRP",
                                        value: dashboard.meanRSRP,
                                        units: "dBm",
                                        decimalPlaces: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: StatsCard(
                                        title: "Mean RSRQ",
                                        value: dashboard.meanRSRQ,
                                        units: "dB",
                                        decimalPlaces: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            // Second row
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: StatsCard(
                                        title: "Coverage Quality",
                                        value: dashboard.coverage,
                                        units: "%",
                                        decimalPlaces: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: StatsCard(
                                        title: "Measurements Count",
                                        value: dashboard.measurementsCount?.toDouble(),
                                        units: "",
                                        decimalPlaces: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                // ------------------------------------------------
                // Map Card
                // ------------------------------------------------
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // ------------------------------------------------
                            // Card Title
                            // ------------------------------------------------
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Coverage Map",
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ------------------------------------------------
                        // Map
                        // ------------------------------------------------
                        Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _mapEnabled
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                      height: 400,
                                      child: dashboard.reading == null
                                          ? Center(child: CircularProgressIndicator())
                                          : CoverageMap(
                                            initialReading: dashboard.reading!,
                                            heatData: dashboard.weightedLatLngPoints,
                                            enabled: _mapEnabled,
                                            enableMap: () {
                                              if (!_mapEnabled) setState(() => _mapEnabled = true);
                                            },
                                      ),
                                    ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app, color: colorScheme.outline, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  _mapEnabled
                                      ? "Tap outside to disable map interaction"
                                      : "Tap to interact with map",
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),

                            HeatmapLegend(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------------
                // Time Series Card
                // ------------------------------------------------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ------------------------------------------------
                        // Card Tile
                        // ------------------------------------------------
                        Row(
                          children: [
                            Icon(
                              Icons.show_chart,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Time Series",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ------------------------------------------------
                        // RSRP Chart
                        // ------------------------------------------------
                        CustomLineChart(
                          data: [
                            ChartData(
                              points: rsrpPoints,
                              name: "RSRP",
                              color: AppColors.chartColor(0,colorScheme),
                            ),
                          ],
                          xData: xData,
                          aspectRatio: 1.6,
                          leftYAxisUnits: "dBm",
                          xAxisUnits: dashboard.timeUnits,
                          title: "Mean RSRP over time",
                          xLabel: "Time",
                          legend: false,
                          xLabelFormatter: (value) =>
                              getDateFromTimestamp(
                                value.toInt(),
                                dashboard.selectedPeriod,
                              ),
                          showXInTooltip: true,
                        ),
                        // ------------------------------------------------
                        // RSRQ Chart
                        // ------------------------------------------------
                        CustomLineChart(
                          data: [
                            ChartData(
                                points: rsrqPoints,
                                name: "RSRQ",
                                color: AppColors.chartColor(1,colorScheme)
                            ),
                          ],
                          xData: xData,
                          aspectRatio: 1.6,
                          title: "Mean RSRQ over time",
                          xLabel: "Time",
                          xAxisUnits: dashboard.timeUnits,
                          leftYAxisUnits: "dB",
                          legend: false,
                          xLabelFormatter: (value) =>
                              getDateFromTimestamp(
                                value.toInt(),
                                dashboard.selectedPeriod,
                              ),
                          showXInTooltip: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
    );
  }
}
