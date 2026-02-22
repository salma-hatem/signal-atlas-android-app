import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/network_reading_provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentNetworkReadingProvider()),
      ],
      child: const App(),
    ),
  );
}
