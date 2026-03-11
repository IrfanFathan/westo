import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/presentation/screens/navigation/main_navigation_screen.dart';

/// DeviceConnectScreen
/// -------------------
/// Guides user to connect phone to ESP32 Wi-Fi and verifies connection.
class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({super.key});

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen> {
  bool _isChecking = false;
  String? _error;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://192.168.4.1/status'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
        return;
      } else {
        _error = 'ESP32 not responding properly';
      }
    } catch (e) {
      _error = 'Not connected to WESTO ESP32 Wi-Fi';
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),

              // Wi-Fi icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primaryLight.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Connect to Device',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 12),

              // Instructions
              Text(
                'Connect your phone to the WESTO ESP32\nWi-Fi hotspot to get started.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),

              const SizedBox(height: 32),

              // Wi-Fi credentials card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _CredentialRow(
                        icon: Icons.wifi,
                        label: 'Network Name',
                        value: 'WESTO_ESP32',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _CredentialRow(
                        icon: Icons.lock_outline,
                        label: 'Password',
                        value: '12345678',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Connect button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkConnection,
                  child: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('I\'m Connected'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for credential display
class _CredentialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CredentialRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
