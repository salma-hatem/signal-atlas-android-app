import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:signal_atlas/services/device_service.dart';
import 'package:signal_atlas/services/dashboard_service.dart';
import 'package:signal_atlas/services/sessions_service.dart';
import 'providers/network_reading_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/server_health_provider.dart';
import 'providers/logging_provider.dart';
import 'providers/sessions_provider.dart';
import 'services/network_readings_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final readingsService = NetworkReadingsService();
  final dashboardService = DashboardService();
  final sessionsService = SessionsService();
  DeviceService.init(readingsService);

  final sessionProvider = SessionProvider(sessionsService);
  final serverHealthProvider = ServerHealthProvider();

  final loggingProvider = LoggingProvider(
    readingsService,
    sessionProvider,
    serverHealthProvider,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sessionProvider),
        ChangeNotifierProvider(create: (_) => serverHealthProvider),
        ChangeNotifierProvider(create: (_) => loggingProvider),
        ChangeNotifierProvider(create: (_) => CurrentNetworkReadingProvider(readingsService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(service: dashboardService)),
      ],
      child: const App(),
    ),
  );
}