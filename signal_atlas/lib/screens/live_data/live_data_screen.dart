import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/providers/network_reading_provider.dart';
import 'package:signal_atlas/providers/logging_provider.dart';

import 'widgets/metric_column.dart';
import 'widgets/singal_kpi_card.dart';
import 'widgets/info_tile.dart';
import 'widgets/health_button.dart';
import 'package:signal_atlas/widgets/signle_accordion.dart';
import 'package:signal_atlas/widgets/widget_tooltip.dart';
import 'package:signal_atlas/widgets/custom_snackbar.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';

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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    final isLoggingEnabled = context.watch<LoggingProvider>().isLogging;

    return Scaffold(
      body: Consumer<CurrentNetworkReadingProvider>(
        builder: (context, liveProvider, _) {
        final latestReading = liveProvider.latestReading;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // Page Title
                  // ------------------------------------------------
                  Text(
                    "Live Data",
                    style: textTheme.headlineMedium
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ------------------------------------------------
                  // Page Body
                  // ------------------------------------------------
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                                                  rangeMin: -140,
                                                  rangeMax: -43,
                                                ),
                                              ),
                                              WidgetTooltip (
                                                tooltip: "Reference Signal Srength Indication",
                                                child: SignalKPICard(
                                                  title: "RSSI",
                                                  value: latestReading?.rssi,
                                                  unit: "dBm",
                                                  rangeMin: -113,
                                                  rangeMax: -51,
                                                ),
                                              ),
                                              WidgetTooltip (
                                                tooltip: "Reference Signal Received Quality",
                                                child: SignalKPICard(
                                                  title: "RSRQ",
                                                  value: latestReading?.rsrq,
                                                  unit: "dB",
                                                  rangeMin: -20,
                                                  rangeMax: -3,
                                                ),
                                              ),
                                              WidgetTooltip (
                                                tooltip: "RSRP in Arbitrary Signal Unit",
                                                child: SignalKPICard(
                                                  title: "ASU",
                                                  value: latestReading?.asu,
                                                  unit: "",
                                                  rangeMin: 0,
                                                  rangeMax: 97,
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
                                      latestReading?.networkType == null
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
                                          title: "Tracking Area Code",
                                          value: latestReading?.trackingAreaCode.toString(),
                                          icon: Icons.map_outlined,
                                          colorScheme: colorScheme,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ------------------------------------------------
                  // Buttons
                  // ------------------------------------------------
                  Row(
                    children: [
                      // ------------------------------------------------
                      // Health
                      // ------------------------------------------------
                      HealthButton(),
                      const SizedBox(width: 8),

                      // ------------------------------------------------
                      // Logging
                      // ------------------------------------------------
                       Expanded(
                        child:
                        WidgetTooltip (
                          tooltip: isLoggingEnabled ? "Stop logging in database" : "Start logging in database",
                          child:OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isLoggingEnabled
                                  ? colorScheme.secondaryContainer.withAlpha(120)
                                  : colorScheme.surface,
                              side: BorderSide(
                                color: isLoggingEnabled
                                  ? colorScheme.secondary
                                  : colorScheme.outline.withAlpha(40),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            ),
                            onPressed: () {
                              context.read<LoggingProvider>().toggleLogging();

                              if (!isLoggingEnabled) {
                                showCustomSnackBar(context, "Enabled logging to database");
                              } else {
                                showCustomSnackBar(context, "Disabled logging");
                              }
                            },
                            icon: const Icon(Icons.terminal),
                            label: isLoggingEnabled
                                ? const Text("Disable Logging")
                                : const Text("Enable Logging"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ------------------------------------------------
                      // Refresh
                      // ------------------------------------------------
                      WidgetTooltip (
                        tooltip: "Refresh",
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            side: BorderSide(
                              color: colorScheme.outline.withAlpha(40),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {},
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
          );
        },
      ),
    );
  }
}
