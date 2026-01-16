import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/presentation/viewmodels/waste_viewmodel.dart';
import 'package:westo/presentation/widgets/status_card.dart';
import 'package:westo/presentation/widgets/waste_gauge.dart';

/// Dashboard screen for monitoring waste-bin status
///
/// Responsibilities:
/// - Display waste level and compressor status
/// - Show accurate ESP32 connection state
/// - Auto-refresh data
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    final viewModel =
    Provider.of<WasteViewModel>(context, listen: false);

    // Initial load
    viewModel.loadInitialStatus();
    viewModel.startRealtimeUpdates();

    // Periodic refresh (fallback if MQTT fails)
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => viewModel.loadInitialStatus(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    Provider.of<WasteViewModel>(context, listen: false)
        .disposeRealtimeUpdates();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<WasteViewModel>(
        builder: (context, viewModel, _) {
          // Loading state
          if (viewModel.isLoading && viewModel.wasteStatus == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Hard error state (ESP32 unreachable)
          if (!viewModel.isEsp32Connected &&
              viewModel.wasteStatus == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off,
                      size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('ESP32 Disconnected'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadInitialStatus,
                    child: const Text('Retry Connection'),
                  ),
                ],
              ),
            );
          }

          final status = viewModel.wasteStatus!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Waste Gauge
                WasteGauge(
                  wasteLevel: status.wasteLevel,
                ),

                const SizedBox(height: 24),

                /// Status Card (IMPORTANT FIX)
                StatusCard(
                  wasteLevel: status.wasteLevel,
                  isConnected: viewModel.isEsp32Connected,
                  isCompressorActive: status.isCompressorActive,
                ),

                const SizedBox(height: 24),

                /// Trigger Compressor Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!viewModel.isEsp32Connected ||
                        status.isCompressorActive)
                        ? null
                        : () async {
                      await viewModel.compressWaste();
                    },
                    child: const Text('Trigger Compressor'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
