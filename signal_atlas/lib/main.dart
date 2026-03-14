import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:signal_atlas/services/api_service.dart';
import 'package:signal_atlas/services/dashboard_service.dart';
import 'providers/network_reading_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/server_health_provider.dart';
import 'providers/logging_provider.dart';
import 'services/network_readings_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final readingsService = await NetworkReadingsService();
  final dashboardService = DashboardService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentNetworkReadingProvider(readingsService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(service: dashboardService),),
        ChangeNotifierProvider(create: (_) => ServerHealthProvider()),
        ChangeNotifierProvider(create: (_) => LoggingProvider(readingsService)),
      ],
      child: const App(),
    ),
  );
}
