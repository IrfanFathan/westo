import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:westo/presentation/screens/splash/splash_screen.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/mqtt_service.dart';
import 'data/repositories/waste_repository_impl.dart';
import 'domain/usecases/get_waste_level.dart';
import 'domain/usecases/trigger_compressor.dart';
import 'presentation/viewmodels/waste_viewmodel.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const WestoApp());
}

/// Root widget of the application
class WestoApp extends StatelessWidget {
  const WestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- DATA LAYER ----
    final apiService = ApiService();
    final mqttService = MqttService();

    final repository = WasteRepositoryImpl(
      apiService: apiService,
      mqttService: mqttService,
    );

    // ---- DOMAIN USE CASES ----
    final getWasteLevel = GetWasteLevel(repository);
    final triggerCompressor = TriggerCompressor(repository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WasteViewModel(
            getWasteLevel: getWasteLevel,
            triggerCompressor: triggerCompressor,
            repository: repository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Westo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
