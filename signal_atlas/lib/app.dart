import 'package:flutter/material.dart';
import 'utilities/theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // light | dark | system
      home: const DashboardPage(),
    );
  }
}
