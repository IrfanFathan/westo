import 'package:flutter/material.dart';

import 'package:westo/core/constants/app_colors.dart';

/// Dedicated trigger toggle card widget
///
/// Displays:
/// - Trigger enable/disable state with icon and label
/// - Color-coded: green when enabled, grey when disabled
/// - Loading state during API call
/// - Cooldown countdown after a successful trigger (e.g. "Cooldown: 24s")
/// - Non-interactable during cooldown via AbsorbPointer
class TriggerCard extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final bool isConnected;
  final bool isInCooldown;
  final int cooldownRemaining;
  final VoidCallback onToggle;

  const TriggerCard({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.isConnected,
    required this.onToggle,
    this.isInCooldown = false,
    this.cooldownRemaining = 0,
  });

  /// Build the subtitle text based on current state
  String _getSubtitleText() {
    if (isLoading) return 'Processing...';
    if (isInCooldown) return 'Cooldown: ${cooldownRemaining}s';
    if (isEnabled) return 'Enabled — System Active';
    return 'Disabled — Tap to Enable';
  }

  /// Get the subtitle text color
  Color _getSubtitleColor() {
    if (isLoading) return AppColors.textDisabled;
    if (isInCooldown) return AppColors.warning;
    return isEnabled ? AppColors.triggerEnabled : AppColors.triggerDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final Color stateColor = isEnabled
        ? AppColors.triggerEnabled
        : AppColors.triggerDisabled;

    /// AbsorbPointer blocks all taps during cooldown
    return AbsorbPointer(
      absorbing: isInCooldown,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: (isLoading || !isConnected || isInCooldown) ? null : onToggle,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Animated icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (isInCooldown
                            ? AppColors.warning
                            : stateColor)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Icon(
                          isInCooldown
                              ? Icons.hourglass_top
                              : isEnabled
                                  ? Icons.power_settings_new
                                  : Icons.power_off_outlined,
                          color: isInCooldown
                              ? AppColors.warning
                              : stateColor,
                          size: 28,
                        ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trigger System',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _getSubtitleText(),
                          key: ValueKey('$isEnabled-$isLoading-$isInCooldown-$cooldownRemaining'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _getSubtitleColor(),
                                fontSize: 13,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle indicator (visually disabled during cooldown)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 52,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isInCooldown
                        ? AppColors.border
                        : isEnabled
                            ? AppColors.triggerEnabled
                            : AppColors.border,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: isEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
