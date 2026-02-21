import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:westo/core/utils/platform.dart';
import 'package:westo/presentation/screens/splash/splash_screen.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/mqtt_service.dart';
import 'data/repositories/waste_repository_impl.dart';
import 'domain/usecases/get_waste_level.dart';
import 'domain/usecases/trigger_compressor.dart';
import 'presentation/viewmodels/waste_viewmodel.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/background_worker.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------
  // Initialize Notification System
  // (Android only)
  // -------------------------------
  await NotificationService.init();

  // -------------------------------
  // Initialize Background Worker
  // (Android/iOS only)
  // -------------------------------
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'wasteCheckTaskId',
      wasteCheckTask,
      frequency: const Duration(minutes: 15),
    );
  }

  runApp(const WestoApp());
}

/// Root widget of the application
class WestoApp extends StatelessWidget {
  const WestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- DATA LAYER ----
    final apiService = ApiService();

    /*
    final mqttService = MqttService();

    ⚠️ MQTT TEMPORARILY DISABLED
    --------------------------------
    Reason:
    - ESP32 firmware does not implement MQTT
    - Prevents false "device disconnected" states
    - REST (HTTP) is the single source of truth

    This block is kept for future upgrades.
    */

    final repository = WasteRepositoryImpl(
      apiService: apiService,
      // mqttService: mqttService, // 🔕 Disabled intentionally
    );

    // ---- DOMAIN USE CASES ----
    final getWasteLevel = GetWasteLevel(repository);
    final triggerCompressor = TriggerCompressor(repository);

    return MultiProvider(
      providers: [
        Provider<WasteRepositoryImpl>.value(
          value: repository,
        ),
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