import 'package:flutter/material.dart';
import '/widgets/map_button.dart';

class SimpleMapController extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFullscreen;
  final VoidCallback onReset;
  final ColorScheme colorScheme;
  final bool isFullScreen;

  const SimpleMapController({
    super.key,
    this.onBack,
    this.onFullscreen,
    required this.onReset,
    required this.colorScheme,
    this.isFullScreen = false,
  });

  double get topOffset => isFullScreen ? 40 : 8;
  double get spacing => isFullScreen ? 64 : 48;
  double get horizontalPadding => isFullScreen ? 16 : 8;
  double get size => isFullScreen ? 28 : 24;
  double get iconPadding => isFullScreen ? 8 : 6;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    int index = 0;

    void addRightButton(Widget button) {
      buttons.add(
        Positioned(
          top: topOffset + (spacing * index),
          right: horizontalPadding,
          child: button,
        ),
      );
      index++;
    }

    // ------------------------------------------------
    // Fullscreen
    // ------------------------------------------------
    if (onFullscreen != null) {
      addRightButton(
        buildMapButton(
          icon: Icons.fullscreen,
          size: size,
          iconPadding: iconPadding,
          tooltip: "Full Screen",
          onPressed: onFullscreen!,
          colorScheme: colorScheme,
        ),
      );
    }

    // ------------------------------------------------
    // Reset
    // ------------------------------------------------
    addRightButton(
      buildMapButton(
        icon: Icons.gps_fixed,
        size: size,
        iconPadding: iconPadding,
        tooltip: "Reset",
        onPressed: onReset,
        colorScheme: colorScheme,
      ),
    );

    return Stack(
      children: [
        // ------------------------------------------------
        // Back
        // ------------------------------------------------
        if (onBack != null)
          Positioned(
            top: topOffset,
            left: horizontalPadding,
            child: buildMapButton(
              icon: Icons.arrow_back,
              size: size,
              iconPadding: iconPadding,
              tooltip: "Back",
              onPressed: onBack!,
              colorScheme: colorScheme,
            ),
          ),

        // ------------------------------------------------
        // Right Buttons
        // ------------------------------------------------
        ...buttons,
      ],
    );
  }
}
