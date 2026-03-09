import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:signal_atlas/providers/network_reading_provider.dart';
import '/models/network_reading.dart';
import '/utilities/theme/app_colors.dart';

import 'package:signal_atlas/widgets/line_chart.dart';
import 'widgets/data_filters_widgets.dart';
import 'widgets/coverage_map.dart';
import 'widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _mapEnabled = false; // to prevent accidentally panning map while scrolling

  NetworkReading? _initialReading;
  String selectedKPI = "RSRP";
  String selectedOperator = "Orange";
  String selectedPeriod = "Past 24h";
  bool showPredictedData = false;

  List<String> kpiList = [
    "RSRP",
    "RSRQ",
  ];
  List<String> operatorList = [
    "Vodafone",
    "Orange",
    "Etisalat",
  ];
  List<String> periodList = [
    "Past 24h",
    "Past week",
    "Past month",
  ];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    final provider = Provider.of<CurrentNetworkReadingProvider>(context);
    if(_initialReading == null) {
      _initialReading = provider.latestReading;
      print("updating readings");
    }

    return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_mapEnabled) {
                    setState(() => _mapEnabled = false);
                  }
                },
                child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // Page Title
                      // ------------------------------------------------
                      Text(
                          "Dashboard",
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
                              // Filters
                              // ------------------------------------------------
                              DataFilters(
                                operatorList: operatorList,
                                selectedOperator: selectedOperator,
                                onOperatorChanged: (value) => setState(() => selectedOperator = value),
                                showPredictedData: showPredictedData,
                                onPredictionChanged: (value) => setState(() => showPredictedData = value),
                                periodList: periodList,
                                selectedPeriod: selectedPeriod,
                                onPeriodChanged: (value) => setState(() => selectedPeriod = value),
                                kpiList: kpiList,
                                selectedKPI: selectedKPI,
                                onKPIChanged: (value) => setState(() => selectedKPI = value),
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
                                                      value: -100,
                                                      units: "dBm",
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: StatsCard(
                                                      title: "Mean RSRQ",
                                                      value: -14,
                                                      units: "dB",
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
                                                      value: 60,
                                                      units: "%",
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: StatsCard(
                                                      title: "Measurements Count",
                                                      value: 1500,
                                                      units: "",
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
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _mapEnabled = true);
                                        },
                                        child: Column(
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
                                                child: IgnorePointer(
                                                  ignoring: !_mapEnabled,
                                                  child: SizedBox(
                                                    height: 400,
                                                    child: _initialReading == null
                                                        ? Center(child: CircularProgressIndicator())
                                                        : CoverageMap(
                                                      initialReading: _initialReading!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  !_mapEnabled
                                                    ? Icon(Icons.touch_app, color: colorScheme.outline, size: 18)
                                                    : SizedBox.shrink(),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    _mapEnabled ? "" : "Tap to interact with map",
                                                    style: TextStyle(color: colorScheme.outline),
                                                  ),
                                                ],
                                              )
                                          ],
                                        )
                                      ),
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
                                          ChartData(points: [], name: "RSRP (dBm)", color: AppColors.chartColor(0,colorScheme)),
                                        ],
                                        xData: [],
                                        aspectRatio: 1.6,
                                        title: "Mean RSRP over time",
                                        xLabel: "Time",
                                        xTicks: 5,
                                        legend: false,
                                      ),
                                      // ------------------------------------------------
                                      // RSRQ Chart
                                      // ------------------------------------------------
                                      CustomLineChart(
                                        data: [
                                          ChartData(points: [], name: "RSRQ (dB)", color: AppColors.chartColor(1,colorScheme)),
                                        ],
                                        xData: [],
                                        aspectRatio: 1.6,
                                        title: "Mean RSRQ over time",
                                        xLabel: "Time",
                                        xTicks: 5,
                                        legend: false,
                                      ),

                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
            ),
          ),
        ),
    );
  }
}
