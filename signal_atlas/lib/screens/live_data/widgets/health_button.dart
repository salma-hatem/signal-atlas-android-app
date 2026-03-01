import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/widgets/widget_tooltip.dart';
import 'package:signal_atlas/providers/server_health_provider.dart';

class HealthButton extends StatefulWidget {
  HealthButton({
    super.key,
  });

  @override
  State<HealthButton> createState() => _HealthButtonState();
}

class _HealthButtonState extends State<HealthButton> {

  @override
  Widget build(BuildContext context) {
    final serverState = context.watch<ServerHealthProvider>().state;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color background = colorScheme.surface;
    Color outline = colorScheme.outline.withAlpha(40);
    Color icon = colorScheme.primary;
    String tooltipText = "Check Server Health";
    switch (serverState) {
      case ServerState.loading:
        background = colorScheme.secondaryContainer;
        outline = colorScheme.secondary.withAlpha(40);
        icon = colorScheme.secondary;
        tooltipText = "Checking Server Status…";
        break;
      case ServerState.success:
        background = colorScheme.primaryContainer.withAlpha(150);
        outline = colorScheme.primary.withAlpha(40);
        icon = colorScheme.primary;
        tooltipText = "Server Online";
        break;
      case ServerState.error:
        background = colorScheme.errorContainer.withAlpha(100);
        outline = colorScheme.error.withAlpha(40);
        icon = colorScheme.error;
        tooltipText = "Server Offline";
        break;
      case ServerState.unknown:
        background = colorScheme.surface;
        outline = colorScheme.outline.withAlpha(40);
        icon = colorScheme.primary;
        tooltipText = "Check Server Health";
    }

    return WidgetTooltip(
      tooltip: tooltipText,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          side: BorderSide(
            color: outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          print("checking health");
          context.read<ServerHealthProvider>().checkHealth();
          print("done checking health");
        },
        child: Icon(
          Icons.monitor_heart_outlined,
          color: icon,
        ),
      ),
    );
  }
}
