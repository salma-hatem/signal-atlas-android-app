import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerBox(BuildContext context,
    {double height = 16, double width = 100}) {
  final colorScheme = Theme.of(context).colorScheme;

  final baseColor = colorScheme.surfaceContainer;
  final highlightColor = colorScheme.surface;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}