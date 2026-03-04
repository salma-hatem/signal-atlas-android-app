import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class ChartData {
  final List<int> points;
  final String name;
  final Color color;

  ChartData({
    required this.points,
    required this.name,
    required this.color,
  });
}

class CustomLineChart extends StatefulWidget {
  final List<ChartData> data;
  final List<double> xData;
  final double? aspectRatio;
  final bool? legend;
  final bool? dualYAxis;
  final String? title;
  final String? yLabel;
  final String? xLabel;
  final String? rightYAxisUnit;
  final String? leftYAxisUnit ;
  final Color? backgroundColor;
  final Color? borderColor;
  final int? yTicks;
  final int? xTicks;
  final double? leftReserved;
  final double? rightReserved;
  final double? bottomReserved;
  final String Function(double value)? xLabelFormatter;
  final String Function(double value)? yLabelFormatter;

  const CustomLineChart({
    required this.data,
    required this.xData,
    this.legend,
    this.dualYAxis,
    this.aspectRatio,
    this.title,
    this.yLabel,
    this.xLabel,
    this.rightYAxisUnit,
    this.leftYAxisUnit,
    this.backgroundColor,
    this.borderColor,
    this.yTicks,
    this.xTicks,
    this.leftReserved,
    this.rightReserved,
    this.bottomReserved,
    this.xLabelFormatter,
    this.yLabelFormatter,
    super.key,
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late List<bool> visibleSeries;

  @override
  void initState() {
    super.initState();
    visibleSeries = List.generate(widget.data.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filter visible series
    final visibleData = List.generate(widget.data.length, (i) => visibleSeries[i] ? widget.data[i] : null)
        .whereType<ChartData>()
        .toList();

    final hasData = widget.xData.isNotEmpty && visibleData.isNotEmpty;

    final xMin = hasData ? widget.xData.first : 0.0;
    final xMax = hasData ? widget.xData.last : 1.0;

    // Compute axis ranges
    double leftMin = 0.0, leftMax = 1.0, leftInterval = 1.0;
    double rightMin = 0.0, rightMax = 1.0, rightInterval = 1.0;

    if (hasData) {
      final leftAxis = calculateAxisRange(visibleData[0].points, ticks: widget.yTicks ?? 5);
      leftMin = leftAxis[0];
      leftMax = leftAxis[1];
      leftInterval = leftAxis[2];

      if (widget.dualYAxis == true && visibleData.length == 2) {
        final rightAxis = calculateAxisRange(visibleData[1].points, ticks: widget.yTicks ?? 5);
        rightMin = rightAxis[0];
        rightMax = rightAxis[1];
        rightInterval = rightAxis[2];
      }
    }

    bool useDual = widget.dualYAxis == true && visibleData.length == 2;
    if (useDual) {
      final rightAxis = calculateAxisRange(visibleData[1].points, ticks: widget.yTicks ?? 5);
      rightMin = rightAxis[0];
      rightMax = rightAxis[1];
      rightInterval = rightAxis[2];
    }


    final xTicks = max(widget.xTicks ?? 5, 2);
    final xRange = max(xMax - xMin, 1.0);
    final xInterval = xRange / (xTicks - 1);

    // Normalize right series if dual Y
    List<LineChartBarData> buildLines() {
      final lines = <LineChartBarData>[];

      for (int i = 0; i < visibleData.length; i++) {
        final series = visibleData[i];

        final spots = List.generate(series.points.length, (index) {
          double y = series.points[index].toDouble();

          // Normalize second series to left axis for overlay
          if (useDual && i == 1) {
            y = (y - rightMin) / (rightMax - rightMin) * (leftMax - leftMin) + leftMin;
          }

          return FlSpot(widget.xData[index], y);
        });

        lines.add(LineChartBarData(
          spots: spots,
          isCurved: true,
          color: series.color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ));
      }

      return lines;
    }

    double getOriginalY(LineBarSpot spot) {
      final seriesIndex = visibleData.indexWhere((d) => d.color == spot.bar.color);
      if (seriesIndex == -1) return spot.y; // fallback

      final series = visibleData[seriesIndex];

      // Find nearest index in xData
      int index = widget.xData.indexWhere((x) => (x - spot.x).abs() < 0.0001);
      if (index == -1 || index >= series.points.length) {
        index = series.points.length - 1; // fallback to last point
      }

      return series.points[index].toDouble();
    }

    // Map chart Y back to original value for tooltip/axis labels
    double scaledToOriginal(double yScaled, double originalMin, double originalMax, double scaleMin, double scaleMax) {
      return (yScaled - scaleMin) / (scaleMax - scaleMin) * (originalMax - originalMin) + originalMin;
    }

    return Column(
      children: [
        // ------------------------------------------------
        // Title
        // ------------------------------------------------
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),

        // ------------------------------------------------
        // Graph
        // ------------------------------------------------
        Column(
          children: [
            // ------------------------------------------------
            // Units row
            // ------------------------------------------------
            if (visibleData.length == 2 && (widget.leftYAxisUnit != null || (useDual && widget.rightYAxisUnit != null)))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left axis unit
                    Text(
                      widget.leftYAxisUnit ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: visibleData[0].color, // match series color
                      ),
                    ),

                    // Right axis unit
                    if (useDual && visibleData.length > 1)
                      Text(
                        widget.rightYAxisUnit ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: visibleData[1].color,
                        ),
                      ),
                  ],
                ),
              ),
            AspectRatio(
              aspectRatio: widget.aspectRatio ?? 1.6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double leftReserved = widget.leftReserved ?? 28.0;
                    final double rightReserved = widget.rightReserved ?? 20.0;
                    final double bottomReserved = widget.bottomReserved ?? 20.0;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        LineChart(
                          LineChartData(
                            clipData: FlClipData.all(),
                            minX: xMin,
                            maxX: xMax,
                            minY: leftMin,
                            maxY: leftMax,
                            backgroundColor: widget.backgroundColor ?? colorScheme.surfaceContainer,
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: true, border: Border.all(color: widget.borderColor ?? colorScheme.outline)),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                // ------------------------------------------------
                                // Y - Axis
                                // ------------------------------------------------
                                axisNameWidget: widget.yLabel != null
                                    ? Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        widget.yLabel!,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    )
                                    : null,
                                axisNameSize: widget.yLabel != null ? 20 : 0,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: leftInterval,
                                  getTitlesWidget: (value, meta) {
                                    final color = visibleData.isNotEmpty ? visibleData[0].color : colorScheme.onSurfaceVariant;
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                  reservedSize: leftReserved,
                                ),
                              ),

                              // Y - Axis (dual axes)
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: useDual,
                                  interval: rightInterval,
                                  getTitlesWidget: (value, meta) {
                                    if (!useDual) return const SizedBox();
                                    final original = scaledToOriginal(value, rightMin, rightMax, leftMin, leftMax);
                                    if (value == meta.min || value == meta.max) {
                                      return const SizedBox();
                                    }
                                    return Text(
                                      original.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: visibleData[1].color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                  reservedSize: rightReserved,
                                ),
                              ),

                              // ------------------------------------------------
                              // X - Axis
                              // ------------------------------------------------
                              bottomTitles: AxisTitles(
                                axisNameWidget: widget.xLabel != null
                                    ? Text(
                                  widget.xLabel!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                )
                                    : null,
                                axisNameSize: widget.xLabel != null ? 20 : 0,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: xInterval > 0 ? xInterval : 1,
                                  getTitlesWidget: (value, meta) {
                                    final label = widget.xLabelFormatter != null
                                        ? widget.xLabelFormatter!(value)
                                        : value.toStringAsFixed(0);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        label,
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  },
                                  reservedSize: bottomReserved,
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineBarsData: buildLines(),

                            // ------------------------------------------------
                            // Tooltip
                            // ------------------------------------------------
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              getTouchedSpotIndicator: (barData, indicators) {
                                return indicators.map((index) => TouchedSpotIndicatorData(
                                  FlLine(color: colorScheme.outline, strokeWidth: 1),
                                  FlDotData(show: true),
                                )).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    double originalY = getOriginalY(spot);
                                    return LineTooltipItem(
                                      originalY.toStringAsFixed(0),
                                      TextStyle(color: spot.bar.color),
                                    );
                                  }).toList();
                                },
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                tooltipBorder: BorderSide(color: widget.borderColor ?? colorScheme.outline, width: 1),
                                getTooltipColor: (spot) => widget.backgroundColor ?? colorScheme.surfaceContainer,
                              ),
                            ),
                          ),
                        ),
                        if (visibleData.isEmpty)
                          Positioned(
                            left: leftReserved,
                            right: 0,
                            top: 0,
                            bottom: bottomReserved,
                            child: IgnorePointer(
                              child: Center(
                                child: Text(
                                  "No data selected",
                                  style: TextStyle(
                                    color: colorScheme.outline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ]
                    );
                  },
                )
              ),
            ),
          ]
        ),

        // ------------------------------------------------
        // Legend
        // ------------------------------------------------
        if (widget.legend ?? true)
          Wrap(
            spacing: 12,
            children: List.generate(widget.data.length, (index) {
              final series = widget.data[index];
              final isVisible = visibleSeries[index];

              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  setState(() {
                    visibleSeries[index] = !visibleSeries[index];
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isVisible ? series.color : series.color.withAlpha(77),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      series.name,
                      style: TextStyle(fontSize: 12, color: isVisible ? null : colorScheme.outline),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  List<double> calculateAxisRange(List<int> values, {int ticks = 5, double paddingFactor = 0.05}) {
    if (values.isEmpty) return [0.0, 1.0, 1.0];

    ticks = max(ticks, 2);

    double minValue = values.reduce(min).toDouble();
    double maxValue = values.reduce(max).toDouble();
    double range = maxValue - minValue;

    if (range == 0) {
      minValue -= 1;
      maxValue += 1;
    } else {
      minValue -= range * paddingFactor;
      maxValue += range * paddingFactor;
    }

    double interval = (maxValue - minValue) / (ticks - 1);
    interval = interval == 0 ? 1 : interval;

    // Snap min/max to interval
    minValue = (minValue / interval).floor() * interval;
    maxValue = (maxValue / interval).ceil() * interval;

    return [minValue, maxValue, interval];
  }
}