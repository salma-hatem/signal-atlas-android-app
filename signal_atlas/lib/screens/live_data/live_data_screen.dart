import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/page_wrapper.dart';

import 'package:signal_atlas/providers/network_reading_provider.dart';
import 'package:signal_atlas/providers/logging_provider.dart';
import '../../utilities/signal_thresholds.dart';
import '/utilities/timestamp_format.dart';
import '/utilities/theme/app_colors.dart';

import 'widgets/metric_column.dart';
import 'widgets/singal_kpi_card.dart';
import 'widgets/info_tile.dart';
import 'package:signal_atlas/widgets/signle_accordion.dart';
import 'package:signal_atlas/widgets/widget_tooltip.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';
import 'package:signal_atlas/widgets/line_chart.dart';

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({
    super.key,
  });

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isLoggingEnabled = context.watch<LoggingProvider>().isLogging;

    return PageWrapper(
      title: "Live Data",
      child: Consumer<CurrentNetworkReadingProvider>(
        builder: (context, liveProvider, _) {
          final latestReading = liveProvider.latestReading;
          final readings = liveProvider.readings;

          final xData = <double>[];
          final rsrpPoints = <int>[];
          final rsrqPoints = <int>[];

          if (readings.isNotEmpty) {
            final firstTimestamp = readings.first.timestamp;

            xData.addAll(
              readings.map((r) => getRelativeSeconds(r.timestamp, firstTimestamp)),
            );
            rsrpPoints.addAll(readings.map((r) => r.rsrp));
            rsrqPoints.addAll(readings.map((r) => r.rsrq));
          }

          return Column(
            children: <Widget>[

              // ------------------------------------------------
              // Network Details Card
              // ------------------------------------------------
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // ------------------------------------------------
                          // Location
                          // ------------------------------------------------
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    latestReading?.country == null || latestReading?.city == null
                                        ? shimmerBox(context, height: 20, width: 120)
                                        : Text("${latestReading?.country}, ${latestReading?.city}", style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    latestReading?.longitudeFormatted == null
                                        || latestReading?.latitudeFormatted == null
                                        || latestReading?.altitudeFormatted == null
                                    ? shimmerBox(context, height: 12, width: 200)
                                    : Text(
                                        "${latestReading?.longitudeFormatted},\t\t\t\t${latestReading?.latitudeFormatted},\t\t\t\t${latestReading?.altitudeFormatted} m",
                                        style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // ------------------------------------------------
                          // Network Type
                          // ------------------------------------------------
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: latestReading?.networkType == null
                              ?shimmerBox(context, height: 12, width: 20)
                              : Text(
                                latestReading!.networkType,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ------------------------------------------------
                      // Network KPIs Accordion
                      // ------------------------------------------------
                      SingleAccordion (
                        // ------------------------------------------------
                        // Collapsed Widget
                        // ------------------------------------------------
                        collapsedWidget: Row(
                          children: [
                            Expanded(
                              child: MetricColumn(
                                title: "Strength",
                                strength: latestReading?.overallStrength,
                                value: latestReading?.rsrp.toDouble(),
                                units: "dBm",
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              color: colorScheme.outline.withAlpha(100),
                            ),
                            Expanded(
                              child: MetricColumn(
                                title: "Quality",
                                strength: latestReading?.level,
                                value: latestReading?.rsrq.toDouble(),
                                units: "dB",
                              ),
                            ),
                          ],
                        ),
                        // ------------------------------------------------
                        // Expanded Widget
                        // ------------------------------------------------
                        expandedWidget: Column(
                          children: [
                            Container(
                              width: 350,
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              color: colorScheme.outline.withAlpha(100),
                            ),
                            SizedBox(height: 4),
                            GridView.count(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2,
                                children: [
                                  WidgetTooltip (
                                    tooltip: "Reference Signal Received Power",
                                    child: SignalKPICard(
                                      title: "RSRP",
                                      value: latestReading?.rsrp,
                                      unit: "dBm",
                                      rangeMin: SignalThresholds.kpiRanges['RSRP']!.min,
                                      rangeMax: SignalThresholds.kpiRanges['RSRP']!.max,
                                    ),
                                  ),
                                  WidgetTooltip (
                                    tooltip: "Reference Signal Srength Indication",
                                    child: SignalKPICard(
                                      title: "RSSI",
                                      value: latestReading?.rssi,
                                      unit: "dBm",
                                      rangeMin: SignalThresholds.kpiRanges['RSSI']!.min,
                                      rangeMax: SignalThresholds.kpiRanges['RSSI']!.max,
                                    ),
                                  ),
                                  WidgetTooltip (
                                    tooltip: "Reference Signal Received Quality",
                                    child: SignalKPICard(
                                      title: "RSRQ",
                                      value: latestReading?.rsrq,
                                      unit: "dB",
                                      rangeMin: SignalThresholds.kpiRanges['RSRQ']!.min,
                                      rangeMax: SignalThresholds.kpiRanges['RSRQ']!.max,
                                    ),
                                  ),
                                  WidgetTooltip (
                                    tooltip: "RSRP in Arbitrary Signal Unit",
                                    child: SignalKPICard(
                                      title: "ASU",
                                      value: latestReading?.asu,
                                      unit: "",
                                      rangeMin: SignalThresholds.kpiRanges['ASU']!.min,
                                      rangeMax: SignalThresholds.kpiRanges['ASU']!.max,
                                    ),
                                  ),
                                ]
                            ),
                          ],
                        ),
                        backgroundColor: colorScheme.surfaceContainer,
                        expandedColor: colorScheme.surfaceContainer,
                        arrowColor: colorScheme.outline.withAlpha(100),
                        borderColor: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // Serving Cell Card
              // ------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cell_tower,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          // ------------------------------------------------
                          // Operator
                          // ------------------------------------------------
                          latestReading?.operatorName == null
                            ?shimmerBox(context, height: 12, width: 200)
                            : Text(
                              latestReading!.operatorName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // PCI and TAC
                      // ------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: InfoTile(
                              title: "Physical Cell ID",
                              value: latestReading?.physicalCellId.toString(),
                              icon: Icons.settings_input_antenna,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                            title: "Cell ID",
                            value: latestReading?.cellId.toString(),
                            icon: Icons.hub_outlined,
                            colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InfoTile(
                              title: "Mobile Country Code",
                              value: latestReading?.mcc.toString(),
                              icon: Icons.public_outlined,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                              title: "Mobile Network Code",
                              value: latestReading?.mnc.toString(),
                              icon: Icons.router_outlined,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                       InfoTile(
                          title: "Tracking Area Code",
                          value: latestReading?.trackingAreaCode.toString(),
                          icon: Icons.map_outlined,
                          colorScheme: colorScheme,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // GPS Accuracy Card
              // ------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Accuracy
                            latestReading?.gpsAccuracy == null
                                ? shimmerBox(context, height: 12, width: 120)
                                : Text(
                              "Accuracy: ±${latestReading!.gpsAccuracy!.toStringAsFixed(1)} m",
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Indoor / Outdoor
                            latestReading?.indoorOutdoor == null
                                ? shimmerBox(context, height: 10, width: 100)
                                : Text(
                              "Environment: ${latestReading!.indoorOutdoor}",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // Line Chart Card
              // ------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.show_chart,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Network KPIs Over Time",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomLineChart(
                        data: [
                          ChartData(
                            points: rsrpPoints,
                            name: "RSRP",
                            color: AppColors.chartColor(0,colorScheme)
                          ),
                          ChartData(
                            points: rsrqPoints,
                            name: "RSRQ",
                            color: AppColors.chartColor(1, colorScheme)
                          ),
                        ],
                        xData: xData,
                        dualYAxis: true,
                        aspectRatio: 1.3,
                        xLabel: "Time (since app start)",
                        xTicks: 5,
                        leftYAxisUnits: "dBm",
                        rightYAxisUnits: "dB",
                        xLabelFormatter: formatSeconds,
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
