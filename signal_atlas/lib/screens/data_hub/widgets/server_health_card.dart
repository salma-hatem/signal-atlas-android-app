import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/utilities/theme/app_colors.dart';
import 'package:signal_atlas/providers/server_health_provider.dart';

class ServerCard extends StatelessWidget {
  const ServerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final serverState = context.watch<ServerHealthProvider>().state;

    Color statusColor;
    String statusText;
    IconData serverIcon;

    switch (serverState) {
      case ServerState.loading:
        statusColor = colorScheme.secondary;
        statusText = "Checking…";
        serverIcon = Icons.cloud_outlined;
        break;
      case ServerState.success:
        statusColor = AppColors.serverStatusColor(true, colorScheme);
        statusText = "Online";
        serverIcon = Icons.cloud_done_outlined;
        break;
      case ServerState.error:
        statusColor = AppColors.serverStatusColor(false, colorScheme);
        statusText = "Offline";
        serverIcon = Icons.cloud_off_outlined;
        break;
      case ServerState.unknown:
      default:
        statusColor = colorScheme.outline;
        statusText = "Unknown";
        serverIcon = Icons.cloud;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<ServerHealthProvider>().checkHealth();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // ------------------------------------------------
              // Main content
              // ------------------------------------------------
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(serverIcon, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      "Server",
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // Refresh Icon
              // ------------------------------------------------
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.refresh,
                  size: 18,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
