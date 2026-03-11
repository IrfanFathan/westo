import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';

/// Circular gauge widget to visualize waste level percentage
///
/// Features:
/// - Animated circular progress with TweenAnimationBuilder
/// - Color changes based on level
/// - Gradient ring effect
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
    final Color gaugeColor = _getGaugeColor(wasteLevel);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Waste Level',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 20),

          // Animated gauge
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$wasteLevel%',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gaugeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(wasteLevel),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: gaugeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Returns color based on waste level
  Color _getGaugeColor(int level) {
    if (level >= 90) {
      return const Color(0xFFFF6B6B); // Light red for dark bg
    } else if (level >= 60) {
      return const Color(0xFFFFD93D); // Light yellow for dark bg
    } else {
      return const Color(0xFF6BCB77); // Light green for dark bg
    }
  }

  /// Returns text label based on waste level
  String _getStatusText(int level) {
    if (level >= 90) {
      return 'CRITICAL';
    } else if (level >= 75) {
      return 'HIGH';
    } else if (level >= 60) {
      return 'MODERATE';
    } else {
      return 'NORMAL';
    }
  }
}
