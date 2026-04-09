import 'package:flutter/material.dart';
import 'map_button.dart';
import 'heatmap_legend.dart';

class MapOverlayControls extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback? onFullscreen;
  final VoidCallback? onBack;
  final VoidCallback onReset;
  final VoidCallback onToggleMarkers;
  final bool markersAlwaysVisible;
  final ColorScheme colorScheme;

  const MapOverlayControls({
    super.key,
    this.isFullScreen = false,
    this.onFullscreen,
    this.onBack,
    required this.onReset,
    required this.onToggleMarkers,
    required this.markersAlwaysVisible,
    required this.colorScheme,
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
    // Full Screen
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
    // Reset Location
    // ------------------------------------------------
    addRightButton(
      buildMapButton(
        icon: Icons.gps_fixed,
        size: size,
        iconPadding: iconPadding,
        tooltip: "Reset Location",
        onPressed: onReset,
        colorScheme: colorScheme,
      ),
    );

    // ------------------------------------------------
    // Toggle Markers
    // ------------------------------------------------
    addRightButton(
      buildMapButton(
        icon: markersAlwaysVisible
            ? Icons.pin_drop_rounded
            : Icons.pin_drop_outlined,
        size: size,
        iconPadding: iconPadding,
        tooltip: "Toggle Markers",
        onPressed: onToggleMarkers,
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
        // Buttons on the Right
        // ------------------------------------------------
        ...buttons,
        // ------------------------------------------------
        // Heatmap Legend
        // ------------------------------------------------
        if (isFullScreen)
          Positioned(
            bottom: 16,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.secondary.withAlpha(150))
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom: 0,
                    ),
                    child: const HeatmapLegend(),
                  ),
                ),
              ),
          )
      ],
    );
  }
}