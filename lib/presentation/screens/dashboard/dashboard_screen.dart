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
/// - Show accurate ESP32 connection state (HTTP-based)
/// - Warn user at 90% and 100% waste level
/// - Trigger compressor with feedback and cooldown
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _shownWarningDialog = false;
  bool _shownCriticalDialog = false;

  @override
  void initState() {
    super.initState();

    final viewModel =
    Provider.of<WasteViewModel>(context, listen: false);

    // Start polling REST data periodically
    viewModel.startPolling();
    
    // Add listener for dialog popups side-effects
    viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    final viewModel = Provider.of<WasteViewModel>(context, listen: false);
    viewModel.removeListener(_onViewModelChange);
    viewModel.stopPolling();
    super.dispose();
  }

  void _onViewModelChange() {
    if (!mounted) return;
    final viewModel = Provider.of<WasteViewModel>(context, listen: false);
    final status = viewModel.wasteStatus;
    
    if (status != null) {
      if (status.wasteLevel >= 90 && status.wasteLevel < 100 && !_shownWarningDialog) {
        _shownWarningDialog = true;
        _showWarningDialog(context, viewModel);
      } else if (status.wasteLevel >= 100 && !_shownCriticalDialog) {
        _shownCriticalDialog = true;
        _showCriticalDialog(context);
      } else if (status.wasteLevel < 90) {
        _shownWarningDialog = false;
        _shownCriticalDialog = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WasteViewModel>(
        builder: (context, viewModel, _) {
          // Loading state (first load)
          if (viewModel.isLoading && viewModel.wasteStatus == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ESP32 unreachable (HTTP failed)
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

                /// Status Card
                StatusCard(
                  wasteLevel: status.wasteLevel,
                  isConnected: viewModel.isEsp32Connected,
                  isCompressorActive: status.isCompressorActive,
                ),

                const SizedBox(height: 24),

                /// Trigger Compressor Button
                if (status.wasteLevel >= 90)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!viewModel.isEsp32Connected ||
                          status.isCompressorActive ||
                          viewModel.isInCooldown)
                          ? null
                          : () async {
                        await viewModel.compressWaste();

                        if (context.mounted) {
                          final isError = viewModel.errorMessage != null;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(isError ? viewModel.errorMessage! : 'Compression started'),
                              backgroundColor: isError ? Colors.red : Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: viewModel.isInCooldown
                          ? const Text('Please wait...')
                          : const Text('Trigger Compressor'),
                    ),
                  ),
      ),
    );
  }

  /// -------------------------------
  /// 90% Warning Dialog
  /// -------------------------------
  void _showWarningDialog(
      BuildContext context,
      WasteViewModel viewModel,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Waste Almost Full'),
        content: const Text(
          'Waste level has reached 90%.\n'
              'Would you like to trigger the compressor?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.compressWaste();

              if (context.mounted) {
                final isError = viewModel.errorMessage != null;
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(isError ? viewModel.errorMessage! : 'Compression started'),
                    backgroundColor: isError ? Colors.red : Colors.green,
                  ),
                );
              }
            },
            child: const Text('Trigger'),
          ),
        ],
      ),
    );
  }

  /// -------------------------------
  /// 100% Critical Dialog
  /// -------------------------------
  void _showCriticalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('⚠ Bin Fully Loaded'),
        content: const Text(
          'Waste bin is 100% full.\n'
              'Immediate action is required.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
