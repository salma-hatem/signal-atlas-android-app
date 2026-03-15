import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  final String? rightYAxisUnits;
  final String? leftYAxisUnits;
  final String? xAxisUnits;

  final Color? backgroundColor;
  final Color? borderColor;

  final int? yTicks;
  final int? xTicks;

  final String Function(double value)? xLabelFormatter;
  final String Function(double value)? yLabelFormatter;

  final bool showXInTooltip;

  const CustomLineChart({
    required this.data,
    required this.xData,
    this.aspectRatio,
    this.legend,
    this.dualYAxis,
    this.title,
    this.yLabel,
    this.xLabel,
    this.rightYAxisUnits,
    this.leftYAxisUnits,
    this.xAxisUnits,
    this.backgroundColor,
    this.borderColor,
    this.yTicks = 3,
    this.xTicks = 6,
    this.xLabelFormatter,
    this.yLabelFormatter,
    this.showXInTooltip = false,
    super.key,
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {

  late List<bool> visibleSeries;
  late TrackballBehavior _trackball;

  @override
  void initState() {
    super.initState();
    visibleSeries = List<bool>.filled(widget.data.length, true);

    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      lineType: TrackballLineType.vertical,
      builder: (context, details) {
        final grouping = details.groupingModeInfo;
        if (grouping == null || grouping.points.isEmpty) return const SizedBox();

        final xValue = grouping.points.first.x as double;
        final formattedX = widget.xLabelFormatter != null
            ? widget.xLabelFormatter!(xValue)
            : xValue.toStringAsFixed(0);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
            border: Border.all(
              color: widget.borderColor ?? Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.xLabel ?? "X"}: $formattedX${widget.xAxisUnits != null ? " (${widget.xAxisUnits})" : ""}",
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),

              // Only show visible series
              for (int i = 0; i < grouping.points.length; i++)
                if (i < widget.data.length && visibleSeries[i])
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.data[i].name}  ",
                        style: TextStyle(
                          color: widget.data[i].color,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "${grouping.points[i].y} ${i == 0 ? widget.leftYAxisUnits ?? '' : widget.rightYAxisUnits ?? ''}",
                        style: TextStyle(
                          color: widget.data[i].color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }

  List<_Point> buildPoints(int seriesIndex) {
    final series = widget.data[seriesIndex];

    return List.generate(series.points.length, (i) {
      return _Point(widget.xData[i], series.points[i].toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasRightSeries = widget.dualYAxis == true && widget.data.length > 1 && visibleSeries[1];

    return Column(
      children: [

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

        // Dual axis units row
        if (widget.dualYAxis == true && widget.data.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.leftYAxisUnits != null)
                  Text(
                    widget.leftYAxisUnits!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.data[0].color, // left axis series color
                    ),
                  ),
                if (widget.rightYAxisUnits != null)
                  Text(
                    widget.rightYAxisUnits!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.data[1].color, // right axis series color
                    ),
                  ),
              ],
            ),
          ),

        AspectRatio(
          aspectRatio: widget.aspectRatio ?? 1.6,
          child: SfCartesianChart(

            plotAreaBackgroundColor:
            widget.backgroundColor ?? colorScheme.surfaceContainer,

            legend: Legend(
              isVisible: widget.legend ?? true,
              toggleSeriesVisibility: true,
            ),

            trackballBehavior: _trackball,

            primaryXAxis: NumericAxis(
              name: 'xAxis',
              desiredIntervals: widget.xTicks,
              title: AxisTitle(text: widget.xAxisUnits != null
                  ? "${widget.xLabel} (${widget.xAxisUnits})"
                  : "${widget.xLabel}"
              ),
              axisLabelFormatter: (args) {
                final value = args.value.toDouble();

                final label = widget.xLabelFormatter != null
                    ? widget.xLabelFormatter!(value)
                    : value.toStringAsFixed(0);

                return ChartAxisLabel(label, null);
              },
            ),

            primaryYAxis: NumericAxis(
              name: 'leftAxis',
              desiredIntervals: widget.yTicks,
              rangePadding: ChartRangePadding.none,
              title: AxisTitle(text: widget.yLabel ?? ""),

              // Only color left axis if dualYAxis is true
              labelStyle: TextStyle(
                color: (widget.dualYAxis == true && widget.data.length > 1)
                    ? widget.data[0].color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),

              axisLabelFormatter: (args) {
                final label = widget.yLabelFormatter != null
                    ? widget.yLabelFormatter!(args.value.toDouble())
                    : args.value.toStringAsFixed(0);
                return ChartAxisLabel(label, null);
              },
            ),

            axes: hasRightSeries
                ? <ChartAxis>[
              NumericAxis(
                name: 'rightAxis',
                desiredIntervals: widget.yTicks,
                rangePadding: ChartRangePadding.none,
                opposedPosition: true,
                labelStyle: TextStyle(color: widget.data[1].color, fontSize: 11),
                axisLabelFormatter: (args) {
                  final label = widget.yLabelFormatter != null
                      ? widget.yLabelFormatter!(args.value.toDouble())
                      : args.value.toStringAsFixed(0);
                  return ChartAxisLabel(label, null);
                },
              )
            ]
                : <ChartAxis>[],

            series: List.generate(widget.data.length, (i) {

              final series = widget.data[i];

              return LineSeries<_Point, double>(
                dataSource: buildPoints(i),
                animationDuration: 0,
                xValueMapper: (_Point p, _) => p.x,
                yValueMapper: (_Point p, _) => p.y,
                name: series.name,
                color: series.color,
                yAxisName: (widget.dualYAxis == true && i == 1)
                    ? 'rightAxis'
                    : 'leftAxis',
                width: 2,
                enableTooltip: true,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _Point {
  final double x;
  final double y;

  _Point(this.x, this.y);
}