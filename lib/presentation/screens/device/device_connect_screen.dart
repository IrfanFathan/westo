import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/presentation/screens/dashboard/dashboard_screen.dart';

/// DeviceConnectScreen
/// -------------------
/// This screen is used to:
/// 1. Ask the user to connect their phone to the ESP32 Wi-Fi hotspot
/// 2. Verify whether ESP32 is reachable (using HTTP)
/// 3. Navigate to the Dashboard once the connection is successful
///
/// NOTE:
/// - We do NOT automatically connect to Wi-Fi
/// - This avoids Android permission & security issues
/// - User connects manually from system Wi-Fi settings
class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({super.key});

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen> {
  // Indicates whether the app is currently checking connection
  bool _isChecking = false;

  // Stores error message if connection fails
  String? _error;

  /// STEP 1: Check ESP32 connectivity
  ///
  /// This method:
  /// - Sends an HTTP request to ESP32 (`/status`)
  /// - If response is OK → device is connected
  /// - If fails → show error
  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      // ESP32 default IP in AP mode is 192.168.4.1
      final response = await http
          .get(Uri.parse('http://192.168.4.1/status'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        // STEP 2: Navigate to dashboard if ESP32 responds
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      } else {
        // ESP32 responded, but not correctly
        _error = 'ESP32 not responding properly';
      }
    } catch (e) {
      // Most common case: phone is not connected to ESP32 Wi-Fi
      _error = 'Not connected to WESTO ESP32 Wi-Fi';
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wi-Fi icon for visual clarity
            Icon(
              Icons.wifi,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),

            // Instruction text
            Text(
              'Connect to WESTO ESP32 Wi-Fi',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Wi-Fi credentials shown to user
            const Text(
              'Wi-Fi Name: WESTO_ESP32\nPassword: 12345678',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Show error if connection fails
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 16),

            // Button to check connection
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkConnection,
                child: _isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('I am Connected'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
