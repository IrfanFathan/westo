import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';

/// Circular gauge widget to visualize waste level percentage
///
/// This widget:
/// - Displays waste level as a circular progress
/// - Changes color based on level
/// - Contains NO business logic
class WasteGauge extends StatelessWidget {
  final int wasteLevel;

  const WasteGauge({
    super.key,
    required this.wasteLevel,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = wasteLevel / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getGaugeColor(wasteLevel),
                ),
              ),
            ),
            Text(
              '$wasteLevel%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _getStatusText(wasteLevel),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Returns color based on waste level
  Color _getGaugeColor(int level) {
    if (level >= 90) {
      return AppColors.error;
    } else if (level >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  /// Returns text label based on waste level
  String _getStatusText(int level) {
    if (level >= 90) {
      return 'Bin Full';
    } else if (level >= 60) {
      return 'Almost Full';
    } else {
      return 'Normal';
    }
  }
}
